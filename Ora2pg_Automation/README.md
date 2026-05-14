# Ora2pg DML import (low disk space)

Import ora2pg DML COPY output **in order**, waiting for each file to finish, then deleting it after import to free space.

## What it expects

- **Entry file**: `data.sql` (created first by ora2pg)
- **In progress**: `tmp_TABLENAME.sql` (ora2pg still writing)
- **Done**: `TABLENAME_data.sql` (after ora2pg renames the tmp file)

## Behaviour

1. Waits for `data.sql` to exist and for its size to be stable (default 5 seconds).
2. **`data.sql` is never deleted** (entry file is kept).
3. If `data.sql` references table data files (`\i './data/X_data.sql'` or `\copy ... from '...'`):
   - Runs the preamble of `data.sql` (e.g. `ALTER TABLE ... DISABLE TRIGGER`) before any `\i` or `\copy`.
   - For each file **in the order it appears in data.sql**:
     - Waits until the corresponding tmp file is gone and the data file exists and is stable.
     - Runs the file with `psql -f` **from OUTPUT_DIR** (so paths like `./data/BK_data.sql` resolve correctly).
     - Deletes only the table data file (not `data.sql`).
4. If `data.sql` does not reference table files, runs `data.sql` once.
5. Processes any remaining `*_data.sql` files under OUTPUT_DIR (wait → run → delete).

**Important:** Set `-d` / `OUTPUT_DIR` to the directory that **contains** `data.sql` and the `data/` subdirectory (e.g. `/home/ora2pg/ora2pg/archive_migration/config/data`). The script runs `psql` with that directory as the current directory so that `\i './data/BK_data.sql'` in `data.sql` resolves correctly.

## Usage

```bash
# From the directory where ora2pg writes (data.sql and *_data.sql)
./import_ora2pg_dml.sh -d /path/to/ora2pg/output -D mydb -U myuser

# Or with environment
export OUTPUT_DIR=/path/to/ora2pg/output
export PGDATABASE=mydb
export PGUSER=myuser
export SEARCH_PATH=myschema,public   # optional
./import_ora2pg_dml.sh
```

### Options

| Option | Meaning |
|--------|--------|
| `-d DIR` | Output directory (default: current dir or `OUTPUT_DIR`) |
| `-h HOST` | PostgreSQL host (default: localhost) |
| `-p PORT` | PostgreSQL port (default: 5432) |
| `-U USER` | PostgreSQL user |
| `-D DB` | PostgreSQL database |
| `-S PATH` | Set `search_path` (e.g. `-S "myschema,public"`) |
| `-s SECS` | Seconds file must be stable to consider complete (default: 5) |
| `-i SECS` | Poll interval in seconds (default: 2) |
| `-n` | Dry run: only print what would be run, no execute/delete |
| `--help` | Show help |

### Example: run while ora2pg is still exporting

```bash
# Terminal 1: ora2pg export
ora2pg -t COPY -c ora2pg.conf

# Terminal 2: import as soon as files are ready (run from project dir)
./import_ora2pg_dml.sh -d /path/to/ora2pg/out -D target_db -U postgres
```

The script waits for each table file to appear and become stable before importing and deleting it, so you can run it in parallel with ora2pg to minimise disk usage.

## Requirements

- `bash`
- `psql` (PostgreSQL client)
- Standard Unix tools: `sed`, `awk`, `grep`, `wc`, `sleep`, `rm`
