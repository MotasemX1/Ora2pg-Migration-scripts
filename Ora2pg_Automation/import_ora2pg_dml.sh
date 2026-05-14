#!/usr/bin/env bash
#
# =============================================================================
# SUMMARY: Ora2pg DML import with low disk usage
# =============================================================================
#
# WHAT IT DOES:
#   Imports ora2pg DML COPY output into PostgreSQL in the same order as
#   data.sql: runs the preamble (ALTER TABLE ... DISABLE TRIGGER, etc.), then
#   each table's *_data.sql one by one. For each file it waits until ora2pg has
#   finished writing (tmp_*.sql gone, *_data.sql present and stable), runs it
#   with psql, then deletes the file. Supports resume (-r) to skip already-
#   imported files and wait for any tmp_* still being written.
#
# WHY WE BUILT IT:
#   Ora2pg with -t COPY writes one data.sql plus many *_data.sql files. Importing
#   everything at once (e.g. psql -f data.sql) needs all files on disk at once,
#   which can run out of space on large migrations. This script imports in order,
#   deletes each file after use, and can run in parallel with ora2pg so disk
#   usage stays low and we don't need space for all exports at once.
#
# USAGE:
#   ora2pg -c config.conf -t COPY -o data.sql -b ./data
#   ./import_ora2pg_dml.sh -d /path/to/data -D mydb -U user   # -r to resume
#
# EXPECTS (in -d directory):
#   - data.sql (entry file; kept, not deleted)
#   - tmp_TABLENAME.sql while ora2pg is writing
#   - TABLENAME_data.sql when done (tmp renamed)
#   - (some resume exports may create TABLENAME_data_resume_data.sql; this script supports both)
#
# =============================================================================
#

set -euo pipefail

# --- Configuration (override with env or edit) ---
OUTPUT_DIR="${OUTPUT_DIR:-.}"
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-}"
PGDATABASE="${PGDATABASE:-}"
# Schema search path (e.g. "myschema,public"). Empty = use server default.
SEARCH_PATH="${PGSEARCHPATH:-${SEARCH_PATH:-}}"
# Wait until file size is stable for this many seconds before considering "finished"
STABLE_SECONDS="${STABLE_SECONDS:-5}"
# How often to check for file completion (seconds)
POLL_INTERVAL="${POLL_INTERVAL:-2}"

# --- Help ---
usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Import ora2pg DML COPY output files in order: data.sql first, then each
table's TABLENAME_data.sql. Waits for each file to finish (tmp_TABLENAME.sql
gone, TABLENAME_data.sql present and stable), runs it, then deletes the file.

Options:
  -d DIR    Output directory (default: current dir, or OUTPUT_DIR)
  -h HOST   PostgreSQL host
  -p PORT   PostgreSQL port
  -U USER   PostgreSQL user
  -D DB     PostgreSQL database
  -S PATH   Set search_path (e.g. -S "myschema,public")
  -s SECS   Seconds file must be stable to consider complete (default: 5)
  -i SECS   Poll interval in seconds (default: 2)
  -n        Dry run: show what would be run, do not execute or delete
  -r        Resume: skip files that no longer exist (already imported), continue from next
  --help    This help

Environment: OUTPUT_DIR, PGHOST, PGPORT, PGUSER, PGDATABASE, SEARCH_PATH or PGSEARCHPATH, STABLE_SECONDS, POLL_INTERVAL
EOF
}

# --- Parse options ---
DRY_RUN=false
RESUME=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d) OUTPUT_DIR="$2"; shift 2 ;;
    -h) PGHOST="$2";     shift 2 ;;
    -p) PGPORT="$2";     shift 2 ;;
    -U) PGUSER="$2";     shift 2 ;;
    -D) PGDATABASE="$2"; shift 2 ;;
    -S) SEARCH_PATH="$2"; shift 2 ;;
    -s) STABLE_SECONDS="$2"; shift 2 ;;
    -i) POLL_INTERVAL="$2";  shift 2 ;;
    -n) DRY_RUN=true; shift ;;
    -r) RESUME=true; shift ;;
    --help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# --- Build psql connection args ---
PSQL_OPTS=(-h "$PGHOST" -p "$PGPORT")
[[ -n "${PGUSER:-}" ]]     && PSQL_OPTS+=(-U "$PGUSER")
[[ -n "${PGDATABASE:-}" ]] && PSQL_OPTS+=(-d "$PGDATABASE")
# Optional search_path for the session
[[ -n "${SEARCH_PATH:-}" ]] && export PGOPTIONS="-c search_path=${SEARCH_PATH}"

# Run a file with psql; path is relative to OUTPUT_DIR (so \i and relative paths in SQL work)
run_psql() {
  local rel_path="$1"
  if "$DRY_RUN"; then
    echo "[DRY RUN] would run: (cd $OUTPUT_DIR && psql ${PSQL_OPTS[*]}${SEARCH_PATH:+ PGOPTIONS=\"-c search_path=$SEARCH_PATH\"} -f $rel_path)"
    return 0
  fi
  (cd "$OUTPUT_DIR" && psql "${PSQL_OPTS[@]}" -f "$rel_path")
}

# --- Wait until a file is "finished": exists and size stable for STABLE_SECONDS ---
wait_file_stable() {
  local file="$1"
  local elapsed=0
  local last_size=-1

  while true; do
    if [[ -f "$file" ]]; then
      local size
      size=$(wc -c < "$file" 2>/dev/null || echo 0)
      if [[ "$size" == "$last_size" ]]; then
        elapsed=$((elapsed + POLL_INTERVAL))
        if [[ $elapsed -ge $STABLE_SECONDS ]]; then
          return 0
        fi
      else
        last_size=$size
        elapsed=0
      fi
    else
      last_size=-1
      elapsed=0
    fi
    sleep "$POLL_INTERVAL"
  done
}

# --- Wait for table data file: no tmp file, and data file exists and stable ---
# rel_path from data.sql is e.g. "data/BK_data.sql" (ora2pg -b ./data). All *_data*.sql files
# live directly in OUTPUT_DIR, so we always use basename(rel_path) e.g. BK_data.sql.
# Sets global ACTUAL_REL_PATH to the filename used for run/delete (always OUTPUT_DIR/ACTUAL_REL_PATH).
wait_table_ready() {
  local rel_path="$1"
  local base_name
  base_name=$(basename "$rel_path")
  local data_file="${OUTPUT_DIR}/${base_name}"
  local table_name=""
  if [[ "$base_name" == *_data_resume.sql ]]; then
    table_name="${base_name%_data_resume.sql}"
  elif [[ "$base_name" == *_data.sql ]]; then
    table_name="${base_name%_data.sql}"
  else
    table_name="${base_name%.sql}"
  fi
  # ora2pg temp file name varies; handle common patterns
  local tmp1="${OUTPUT_DIR}/tmp_${table_name}.sql"
  local tmp2="${OUTPUT_DIR}/tmp_${table_name}_data.sql"
  local tmp3="${OUTPUT_DIR}/tmp_${table_name}_data_resume_data.sql"

  while [[ -f "$tmp1" ]] || [[ -f "$tmp2" ]] || [[ -f "$tmp3" ]]; do
    echo "  Waiting for ora2pg to finish (tmp file exists)"
    sleep "$POLL_INTERVAL"
  done

  while [[ ! -f "$data_file" ]]; do
    echo "  Waiting for data file: $data_file"
    sleep "$POLL_INTERVAL"
  done

  echo "  Waiting for file to be stable: $data_file"
  wait_file_stable "$data_file"
  ACTUAL_REL_PATH="$base_name"
}

# --- Wait for data.sql to exist and be stable ---
wait_entry_ready() {
  local entry="${OUTPUT_DIR}/data_resume.sql"
  while [[ ! -f "$entry" ]]; do
    echo "Waiting for entry file: $entry"
    sleep "$POLL_INTERVAL"
  done
  echo "Waiting for entry file to be stable: $entry"
  wait_file_stable "$entry"
}

# --- Extract ordered list of \i paths from data.sql (\i './data/X_data.sql' or \i "path") ---
# Returns paths relative to OUTPUT_DIR (leading ./ removed). Also matches \copy/COPY from '..._data*.sql'.
get_table_paths_from_data_sql() {
  local data_sql="$1"
  # \i '...' or \i "..."
  sed -n "s/.*\\\\i[[:space:]]*['\"]\\([^'\"]*_data[^'\"]*\\.sql\\)['\"].*/\1/p" "$data_sql" 2>/dev/null | while read -r p; do
    # Normalize: remove leading ./
    [[ "$p" = ./ ]] && continue
    echo "${p#./}"
  done
  # If no \i found, fall back to \copy/COPY from '..._data*.sql' (basename only)
  if ! grep -q '\\i.*_data.*\.sql' "$data_sql" 2>/dev/null; then
    sed -n "s/.*[Ff][Rr][Oo][Mm][[:space:]]*['\"]\?[^'\"]*\\([^'\" /]*\\)_data[^'\"]*\\.sql.*/\\1_data.sql/p" "$data_sql" 2>/dev/null
  fi
}

# --- Main ---
main() {
  if [[ -n "${PGDATABASE:-}" ]]; then
    echo "Database: $PGDATABASE @ $PGHOST:$PGPORT"
  fi
  echo "Output dir: $OUTPUT_DIR"
  echo ""

  # 1) Wait for and run entry file (data.sql)
  wait_entry_ready
  ENTRY="${OUTPUT_DIR}/data_resume.sql"

  # If data.sql contains \i '..._data*.sql' or \copy from '...', we run preamble then each file in order (and delete table files only; keep data.sql).
  if grep -qE "\\\\i.*_data.*\\.sql|_data.*\\.sql" "$ENTRY" 2>/dev/null; then
    echo "Entry file references table data files; will run preamble then each file in order (data.sql is kept)."
    PATHS=()
    while IFS= read -r p; do
      [[ -n "$p" ]] && PATHS+=("$p")
    done < <(get_table_paths_from_data_sql "$ENTRY")

    if [[ ${#PATHS[@]} -eq 0 ]]; then
      echo "No table data file paths found in $ENTRY; running entry file as-is."
      run_psql "data.sql"
    else
      # Preamble = all lines that are NOT \i ... _data*.sql (so ALTER TABLE, SET, etc. only; no \i)
      PREAMBLE="${OUTPUT_DIR}/.data_preamble.sql"
      if ! "$DRY_RUN"; then
        awk '!/\\i[[:space:]]*.*_data.*\\.sql/' "$ENTRY" > "$PREAMBLE"
        if [[ -s "$PREAMBLE" ]]; then
          (cd "$OUTPUT_DIR" && psql "${PSQL_OPTS[@]}" -f ".data_preamble.sql")
          echo "Executed preamble from data.sql"
        fi
        rm -f "$PREAMBLE"
      fi

      for rel_path in "${PATHS[@]}"; do
        base_name=$(basename "$rel_path")
        data_file="${OUTPUT_DIR}/${base_name}"
        echo "--- File: $rel_path ---"
        if "$RESUME" && [[ ! -f "$data_file" ]]; then
          echo "  Skipping (already imported or not yet present): $base_name"
          continue
        fi
        wait_table_ready "$rel_path"
        run_psql "$ACTUAL_REL_PATH"
        if ! "$DRY_RUN"; then
          rm -f "${OUTPUT_DIR}/${ACTUAL_REL_PATH}"
          echo "Deleted ${OUTPUT_DIR}/${ACTUAL_REL_PATH}"
        fi
      done
      # Keep data.sql (do not delete)
    fi
  else
    echo "Running entry file: data.sql"
    run_psql "data.sql"
    # Keep data.sql (do not delete)
  fi

  # 2) Wait for any tmp_* files (ora2pg still writing) to finish, then process the resulting *_data.sql
  echo ""
  echo "Checking for tmp files still being written..."
  while true; do
    tmp_file=""
    while IFS= read -r -d '' f; do
      tmp_file="$f"
      break
    done < <(find "$OUTPUT_DIR" -maxdepth 1 -name 'tmp_*.sql' -print0 2>/dev/null)
    [[ -z "$tmp_file" ]] && break
    base=$(basename "$tmp_file" .sql)
    base_no_tmp="${base#tmp_}"
    if [[ "$base_no_tmp" == *_data_resume ]]; then
      final_name="${base_no_tmp}.sql"
    elif [[ "$base_no_tmp" == *_data ]]; then
      final_name="${base_no_tmp}.sql"
    else
      final_name="${base_no_tmp}_data.sql"
    fi
    final_file="${OUTPUT_DIR}/${final_name}"
    echo "--- Waiting for tmp to finish: $(basename "$tmp_file") → $final_name ---"
    while [[ -f "$tmp_file" ]]; do
      echo "  Waiting for ora2pg to finish: $tmp_file"
      sleep "$POLL_INTERVAL"
    done
    while [[ ! -f "$final_file" ]]; do
      echo "  Waiting for data file: $final_file"
      sleep "$POLL_INTERVAL"
    done
    echo "  Waiting for file to be stable: $final_file"
    wait_file_stable "$final_file"
    run_psql "$final_name"
    if ! "$DRY_RUN"; then
      rm -f "$final_file"
      echo "Deleted $final_file"
    fi
  done

  # 3) Any remaining *_data*.sql files (exclude tmp_*)
  echo ""
  echo "Checking for remaining *_data*.sql files..."
  while IFS= read -r -d '' data_file; do
    rel_path="${data_file#${OUTPUT_DIR}/}"
    echo "--- File (remaining): $rel_path ---"
    wait_file_stable "$data_file"
    run_psql "$rel_path"
    if ! "$DRY_RUN"; then
      rm -f "$data_file"
      echo "Deleted $data_file"
    fi
  done < <(find "$OUTPUT_DIR" -maxdepth 1 -name '*_data*.sql' ! -name 'tmp_*' -print0 2>/dev/null)

  echo "Done."
}

main "$@"
