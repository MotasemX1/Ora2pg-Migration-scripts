## 🔧 Oracle → PostgreSQL Migration Execution Plan  
**MPAY & PPS – Export, Cleansing, Ora2Pg, Import, and Validation**

---

## 1. Oracle Export Phase (Source Schemas)

### 1.1 MPAY – Export (Split Metadata / Data / Objects)

```bash
# Metadata only (excluding tables/objects that will be handled separately)
expdp \
  directory=cln \
  dumpfile=mpay_metadata_exclude_exp.dmp \
  schemas=MPAY_DINARAK_PROD \
  content=METADATA_ONLY \
  parfile=EXCLUDE_MPAY_DDL.PAR \
  exclude=grant,INDEX,CONSTRAINT,REF_CONSTRAINT,TRIGGER

# Data only (excluding some tables)
expdp \
  directory=cln \
  dumpfile=mpay_metadata_1.dmp \
  logfile=mpay_metadata1.log \
  schemas=MPAY_DINARAK_PROD \
  content=DATA_ONLY \
  parfile=EXCLUDE_MPAY_TABLES.PAR \
  exclude=grant,INDEX,CONSTRAINT,REF_CONSTRAINT,TRIGGER

# Objects only (indexes / constraints / triggers / ref constraints)
expdp \
  directory=cln \
  dumpfile=object_only_exp.dmp \
  logfile=object_only_exp.log \
  schemas=MPAY_DINARAK_PROD \
  include=INDEX,CONSTRAINT,REF_CONSTRAINT,TRIGGER
```

---

### 1.2 PPS – Export (Split Metadata / Data / Objects)

```bash
# Metadata only (excluding grants, indexes, constraints, triggers)
expdp \
  directory=cln \
  dumpfile=pps_metadata_exclude_exp.dmp \
  schemas=CLIQMW \
  content=METADATA_ONLY \
  exclude=grant,INDEX,CONSTRAINT,REF_CONSTRAINT,TRIGGER

# Data only (excluding some tables)
expdp \
  directory=cln \
  dumpfile=pps_metadata_1.dmp \
  logfile=pps_metadata1.log \
  schemas=CLIQMW \
  content=DATA_ONLY \
  parfile=EXCLUDE_PPS_TABLES.PAR \
  exclude=grant,INDEX,CONSTRAINT,REF_CONSTRAINT,TRIGGER

# Objects only (indexes / constraints / triggers / ref constraints)
expdp \
  directory=cln \
  dumpfile=pps_object_only_exp.dmp \
  logfile=pps_object_only_exp.log \
  schemas=CLIQMW \
  include=INDEX,CONSTRAINT,REF_CONSTRAINT,TRIGGER
```

---

## 2. Oracle Import & Cleansing (Pre-Ora2Pg)

### 2.1 MPAY – Import into Staging Schema and Data Cleansing

#### 2.1.1 Import Metadata (No Indexes/Constraints/Triggers)

```bash
impdp \
  directory=cln \
  dumpfile=mpay_metadata_exclude_exp.dmp \
  logfile=mpay_metadata_exclude_imp.log \
  schemas=MPAY_DINARAK_PROD \
  remap_schema=MPAY_DINARAK_PROD:MPAY_PG
```

**Note:** `MPAY_CLIQPURPOSE_NLS.DESCRIPTION` is `VARCHAR2(100 CHAR)` in PROD dump; widen it:

```sql
ALTER TABLE MPAY_PG.MPAY_CLIQPURPOSE_NLS
  MODIFY (DESCRIPTION VARCHAR2(200 CHAR));
```

#### 2.1.2 Import Data and Apply Cleansing Updates

```bash
impdp \
  directory=cln \
  dumpfile=mpay_metadata_1.dmp \
  logfile=mpay_metadata2.log \
  schemas=MPAY_DINARAK_PROD \
  remap_schema=MPAY_DINARAK_PROD:MPAY_PG
```

**Post‑import data cleansing:**

```sql
UPDATE MPAY_PG.MPAY_NETWORKMANAGEMENTS SET REFLASTMSGLOGID = NULL;
UPDATE MPAY_PG.MPAY_CUSTOMERS           SET REFLASTMSGLOGID = NULL;
UPDATE MPAY_PG.MPAY_CORPORATES          SET REFLASTMSGLOGID = NULL;

UPDATE MPAY_PG.MPAY_CUSTOMERMOBILES
   SET Z_DELETED_FLAG = 0
 WHERE Z_DELETED_FLAG IS NULL;

UPDATE MPAY_PG.MPAY_CORPOARTESERVICES
   SET Z_DELETED_FLAG = 0
 WHERE Z_DELETED_FLAG IS NULL;

COMMIT;
```

---

### 2.2 MPAY – Create Staging Schema and Tablespace (if not exists)

```sql
CREATE USER MPAY_PG
  IDENTIFIED BY MPAY_PG
  DEFAULT TABLESPACE MPAY_TAB0002
  TEMPORARY TABLESPACE TEMP;

-- Grant Roles
GRANT CONNECT            TO MPAY_PG;
GRANT DBA                TO MPAY_PG;
GRANT RESOURCE           TO MPAY_PG;
GRANT SELECT_CATALOG_ROLE TO MPAY_PG;
ALTER USER MPAY_PG DEFAULT ROLE ALL;

-- Grant System Privileges
GRANT CREATE ANY MATERIALIZED VIEW TO MPAY_PG;
GRANT CREATE ANY SYNONYM           TO MPAY_PG;
GRANT CREATE DATABASE LINK         TO MPAY_PG;
GRANT CREATE SESSION               TO MPAY_PG;
GRANT QUERY REWRITE                TO MPAY_PG;
GRANT SELECT ANY DICTIONARY        TO MPAY_PG;
GRANT UNLIMITED TABLESPACE         TO MPAY_PG;

-- Grant Object Privileges
GRANT EXECUTE, DEBUG ON SYS.DBMS_CRYPTO TO MPAY_PG;
```

```sql
CREATE TABLESPACE "MPAYPG_TBS" DATAFILE
  '/u01/app/oracle/oradata/EE/MPAYPG_TBS.DBF' SIZE 200M AUTOEXTEND ON NEXT 200M MAXSIZE UNLIMITED
  LOGGING
  FORCE LOGGING
  DEFAULT
    NO INMEMORY
  ONLINE
  EXTENT MANAGEMENT LOCAL AUTOALLOCATE
  BLOCKSIZE 8K
  SEGMENT SPACE MANAGEMENT AUTO
  FLASHBACK ON;
```

---

### 2.3 PPS – Import into Staging Schema and Tablespace Mapping

#### 2.3.1 Import Metadata (No Indexes/Constraints/Triggers)

```bash
impdp \
  directory=cln \
  dumpfile=pps_metadata_exclude_exp.dmp \
  logfile=pps_metadata_exclude_imp.log \
  schemas=CLIQMW \
  remap_schema=CLIQMW:CLIQMW_PG \
  remap_tablespace=PPS_TAB01:PPSPG_TBS \
  remap_tablespace=MPAY_TAB0002:PPSPG_TBS
```

#### 2.3.2 Import Data

```bash
impdp \
  directory=cln \
  dumpfile=pps_metadata_1.dmp \
  logfile=pps_metadata2.log \
  schemas=CLIQMW \
  remap_schema=CLIQMW:CLIQMW_PG \
  remap_tablespace=PPS_TAB01:PPSPG_TBS \
  remap_tablespace=MPAY_TAB0002:PPSPG_TBS
```

#### 2.3.3 Import Remaining Objects

```bash
impdp \
  directory=cln \
  dumpfile=pps_object_only_exp.dmp \
  logfile=pps_object_only_imp.log \
  schemas=CLIQMW \
  remap_schema=CLIQMW:CLIQMW_PG \
  remap_tablespace=PPS_TAB01:PPSPG_TBS \
  remap_tablespace=MPAY_TAB0002:PPSPG_TBS
```

---

### 2.4 PPS – Create Staging Schema and Tablespace (if not exists)

```sql
CREATE USER CLIQMW_PG
  IDENTIFIED BY CLIQMW_PG
  DEFAULT TABLESPACE PPSPG_TBS
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT
  ACCOUNT UNLOCK;

-- Grant Roles
GRANT CONNECT            TO CLIQMW_PG;
GRANT DBA                TO CLIQMW_PG;
GRANT RESOURCE           TO CLIQMW_PG;
GRANT SELECT_CATALOG_ROLE TO CLIQMW_PG;
ALTER USER CLIQMW_PG DEFAULT ROLE ALL;

-- Grant System Privileges
GRANT CREATE ANY MATERIALIZED VIEW TO CLIQMW_PG;
GRANT CREATE ANY SYNONYM           TO CLIQMW_PG;
GRANT CREATE DATABASE LINK         TO CLIQMW_PG;
GRANT CREATE SESSION               TO CLIQMW_PG;
GRANT QUERY REWRITE                TO CLIQMW_PG;
GRANT SELECT ANY DICTIONARY        TO CLIQMW_PG;
GRANT UNLIMITED TABLESPACE         TO CLIQMW_PG;

-- Grant Object Privileges
GRANT EXECUTE, DEBUG ON SYS.DBMS_CRYPTO TO CLIQMW_PG;
```

---

## 3. Moving Cleansed Dump to Ora2Pg Source

### 3.1 Export & Import Cleansed MPAY_PG Dump

```bash
expdp dumpfile=MPAY_PG.dmp LOGFILE=MPAY_PG.log SCHEMAS=MPAY_PG

impdp dumpfile=MPAY_PG.dmp \
  remap_tablespace=MPAY_TAB01:MPAYPG_TBS \
  remap_tablespace=MPAY_TAB0002:MPAYPG_TBS \
  remap_tablespace=MPAY_TAB0001:MPAYPG_TBS \
  LOGFILE=log.log
```

### 3.2 Transfer Dump to Ora2Pg Host

```bash
rsync -av --progress \
  -e "ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa" \
  oracle@10.99.151.12:/backup/PILOT_CLEAN_DUMP/MPAY_PG.dmp .
```

---

### 3.3 JFW Workflow Cleansing (MPAY Only)

> **Important:** Execute this cleansing step **right before** running Ora2Pg extraction to remove orphaned workflow entries and ensure data integrity.

#### 3.3.1 Create Workflow Mapping Table and Collection Procedure

```sql
CREATE TABLE workflow_mapping (
    table_name     VARCHAR2(300),
    workflow_notused  NUMBER(30,0)
);

CREATE OR REPLACE PROCEDURE collect_workflow_ids (
    p_schema_name IN VARCHAR2
)
IS
    v_sql   CLOB;
BEGIN
    FOR t IN (
        SELECT table_name
        FROM all_tab_columns
        WHERE owner = UPPER(p_schema_name)
          AND column_name = 'Z_WORKFLOW_ID'
        GROUP BY table_name
    )
    LOOP
        v_sql :=
            'INSERT INTO WORKFLOW_MAPPING (table_name, workflow_notused) ' ||
            'SELECT ''' || t.table_name || ''', Z_WORKFLOW_ID ' ||
            'FROM ' || p_schema_name || '.' || t.table_name ||
            ' WHERE Z_WORKFLOW_ID IS NOT NULL';
        EXECUTE IMMEDIATE v_sql;
    END LOOP;

    COMMIT;
END collect_workflow_ids;
/
```

#### 3.3.2 Collect Workflow IDs from MPAY_PG Schema

```sql
BEGIN
    collect_workflow_ids('MPAY_PG');
END;
/
```

#### 3.3.3 Create Index on Workflow Mapping

```sql
CREATE INDEX idx_wf_map_notused
ON workflow_mapping (workflow_notused)
ONLINE;
```

#### 3.3.4 Remove Orphaned Workflow Steps

```sql
DELETE /*+ PARALLEL(4) */ FROM jfw_os_currentstep c
WHERE NOT EXISTS (
    SELECT 1
    FROM workflow_mapping w
    WHERE w.workflow_notused = c.entry_id
);
```

#### 3.3.5 Clean and Rebuild `jfw_os_wfentry` Table

```sql
-- Disable foreign key constraints temporarily
ALTER TABLE JFW_OS_CURRENTSTEP DISABLE CONSTRAINT FK_LVJJQ06TKYPLY3PTCEN2IFP3L;
ALTER TABLE JFW_OS_HISTORYSTEP DISABLE CONSTRAINT FK_YI1VE6WBG1G1IIGT4WPSS9UJ;

-- Create new table with only valid workflow entries
CREATE TABLE jfw_os_wfentry_new NOLOGGING AS
SELECT c.*
FROM jfw_os_wfentry c
WHERE EXISTS (
   SELECT 1
   FROM workflow_mapping w
   WHERE w.workflow_notused = c.id
);

-- Truncate and repopulate original table
TRUNCATE TABLE jfw_os_wfentry;
INSERT /*+ APPEND */ INTO jfw_os_wfentry
SELECT * FROM jfw_os_wfentry_new;

-- Re-enable constraints
ALTER TABLE JFW_OS_CURRENTSTEP ENABLE CONSTRAINT FK_LVJJQ06TKYPLY3PTCEN2IFP3L;
ALTER TABLE JFW_OS_HISTORYSTEP ENABLE CONSTRAINT FK_YI1VE6WBG1G1IIGT4WPSS9UJ;

-- Cleanup temporary table
DROP TABLE jfw_os_wfentry_new;
```

**Notes:**
- This step removes orphaned workflow entries that are not referenced by any table with `Z_WORKFLOW_ID` column.
- The `NOLOGGING` and `APPEND` hints improve performance for large tables.
- Execute this **before** running Ora2Pg to ensure clean data extraction.

---

## 4. Ora2Pg Extraction (Oracle → PostgreSQL SQL)

### 4.1 MPAY – Ora2Pg Commands

```bash
# Tables, constraints, FKs, indexes
ora2pg -c ora2pg-mpay.conf -t TABLE   -o tables.sql

# Sequences
ora2pg -c ora2pg-mpay.conf -t SEQUENCE -o sequences.sql

# Data (COPY)
nohup ora2pg -j 4 -c ora2pg-mpay.conf -t COPY -o data.sql -b ./data \
  > ora2pg_tables.log 2>&1 &
```

### 4.2 PPS – Ora2Pg Commands

```bash
# Tables, constraints, FKs, indexes
ora2pg -c ora2pg-pps.conf -t TABLE   -o tables.sql

# Sequences
ora2pg -c ora2pg-pps.conf -t SEQUENCE -o sequences.sql

# Data (COPY)
ora2pg -c ora2pg-pps.conf -t COPY -o data.sql -b ./data
```

---

## 5. Cleansing Ora2Pg Output (Pre‑PostgreSQL)

### 5.1 Remove Unwanted TRUNCATE Statements

```bash
sed -i '/^TRUNCATE TABLE/d' *.sql
```

### 5.2 Standardize `z_org_id` Values (Patch SQL Generator)

```sql
SELECT
    'UPDATE ' || quote_ident(table_schema) || '.' || quote_ident(table_name) ||
    ' SET z_org_id = z_orag_id WHERE z_tenant_id = ''PPS'';' AS update_sql
FROM information_schema.columns
WHERE column_name = 'z_org_id'
  AND table_schema = 'SCHEMA_NAME'
ORDER BY table_schema, table_name;
```

Run generated statements in PostgreSQL as needed.

### 5.3 Clean Temporary Table Syntax (Remove `pgtt`)

```bash
sed -i -E '
/^LOAD.*pgtt/d;                                     
s@/\*GLOBAL\*/[[:space:]]*TEMPORARY[[:space:]]*@@g;  
s/[[:space:]]*ON[[:space:]]+COMMIT[[:space:]]+(DELETE|PRESERVE)[[:space:]]+ROWS;?//Ig
' tables.sql
```

### 5.4 Remove Specific Tables from MPAY `data.sql`

```bash
sed -i -E '/hte_meps_reasons|hte_meps_transactiontypes|hte_mpay_transactions|ht_jfw_result_columns|ht_jfw_summary_widgets|ID_ENG|ht_jfw_wf_argument|temp_unlock_commands/Id' data.sql 
```

### 5.5 Clean MPAY Indexes (Remove `nlssort` and `binary_ci`)

```bash
sed -i -E "
  s/[[:space:]]*collate[[:space:]]+binary_ci//Ig;
  s/nlssort\(\(([^)]*)\),[[:space:]]*'[^']*'\)/\1/Ig;
  s/nlssort\(\(([^)]*)\),[[:space:]]*''[^'']*''\)/\1/Ig;
  s/::text//g;
" INDEXES_tables.sql
```

---

## 6. PostgreSQL Import Phase (MPAY/PPS)

> **Important:** Use the correct `SCHEMA_NAME` for MPAY vs PPS and adjust `search_path` accordingly.

### 6.1 Import Tables

```bash
psql -U postgres -d mpay_db \
  -c "SET search_path TO SCHEMA_NAME;" \
  -f schema/tables.sql
```

### 6.2 Import Sequences

```bash
psql -U postgres -d mpay_db \
  -c "SET search_path TO SCHEMA_NAME;" \
  -f schema/sequences.sql
```

### 6.3 Import Data (COPY)

```bash
nohup psql \
  -U postgres \
  -d mpay_db \
  -v ON_ERROR_STOP=1 \
  -c "SET search_path TO mpayprodpg;" \
  -f data/data-1.sql \
  > data_load.log 2>&1 &
```

*(Repeat / extend for full data set as needed.)*

### 6.4 Import Indexes

```bash
psql -U postgres -d mpay_db \
  -c "SET search_path TO mpayprodpg;" \
  -f schema/INDEXES_tables.sql
```

### 6.5 Fix `numeric(38)` → `bigint` (Before FKs)

```bash
psql -U postgres -d mpay_db -c "
SELECT 'ALTER TABLE ' || table_schema || '.' || table_name ||
       ' ALTER COLUMN ' || column_name || ' TYPE bigint USING ' || column_name || '::bigint;'
FROM information_schema.columns
WHERE table_schema = 'SCHEMA_NAME'
  AND data_type = 'numeric'
  AND numeric_precision = 38
  AND (numeric_scale = 0 OR numeric_scale IS NULL);
" > fix_numeric_38.sql

psql -U postgres -d mpay_db \
  -c "SET search_path TO SCHEMA_NAME;" \
  -f fix_numeric_38.sql
```

### 6.6 Type Patch – Numeric to Boolean (MPAY)

```sql
ALTER TABLE mpay_switchwallet
  ALTER COLUMN z_deleted_flag
  TYPE bool USING CASE WHEN z_deleted_flag = 1 THEN true ELSE false END;

ALTER TABLE mpay_wallettypes
  ALTER COLUMN z_editable
  TYPE bool USING CASE WHEN z_editable = 1 THEN true ELSE false END;

ALTER TABLE mpay_wallettypes
  ALTER COLUMN z_deleted_flag
  TYPE bool USING CASE WHEN z_deleted_flag = 1 THEN true ELSE false END;
```

### 6.7 Type Patch – `varchar(128)` to `bigint`

```sql
ALTER TABLE mpayuat.mpay_banks
  ALTER COLUMN settlementparticipant
  TYPE bigint USING settlementparticipant::bigint;
```

### 6.8 Import Constraints (PK, UNIQUE, CHECK)

```bash
psql -U postgres -d mpay_db \
  -c "SET search_path TO SCHEMA_NAME;" \
  -f schema/CONSTRAINTS_tables.sql
```

### 6.9 Import Foreign Keys

```bash
psql -U postgres -d mpay_db \
  -c "SET search_path TO SCHEMA_NAME;" \
  -f schema/FKEYS_tables.sql
```

### 6.10 Import Functions (MPAY Only)

```bash
psql -U postgres -d mpay_db \
  -c "SET search_path TO SCHEMA_NAME;" \
  -f schema/Functions_Mpay_Postgres.sql
```

### 6.11 Update Value Providers (MPAY Only)

```bash
psql -U postgres -d mpay_db \
  -c "SET search_path TO SCHEMA_NAME;" \
  -f Value-Providers-Fix.sql
```

### 6.12 Insert Missing Views (e.g., `meps_messagetypes`)

Create/restore any missing views manually via SQL scripts as needed.

### 6.13 Deadlock Patch (Deferrable FK)

```sql
ALTER TABLE mpay_jvdetails
  DROP CONSTRAINT fk_mh73aj2mqqbuv7fni99xhjf9c;

ALTER TABLE mpay_jvdetails
  ADD CONSTRAINT fk_mh73aj2mqqbuv7fni99xhjf9c
  FOREIGN KEY (refaccountid)
  REFERENCES mpay_accounts (id)
  DEFERRABLE INITIALLY DEFERRED;
```

### 6.14 (Optional) Import Logical Tables

```bash
psql -U postgres -d mpay_db \
  -c "SET search_path TO SCHEMA_NAME;" \
  -f schema/LOGICAL_tables.sql
```

---

## 7. Recovery & Cleanup Utilities (PostgreSQL)

### 7.1 Drop All Foreign Keys

```bash
psql -U postgres -d mpay_db -At -c "
SELECT 'ALTER TABLE ' || tc.table_schema || '.' || tc.table_name ||
       ' DROP CONSTRAINT ' || tc.constraint_name || ';'
FROM information_schema.table_constraints AS tc
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'SCHEMA_NAME';" | psql -U postgres -d mpay_db
```

### 7.2 Drop All Constraints (PK / UNIQUE / FK)

```bash
psql -U postgres -d mpay_db -At -c "
SELECT 'ALTER TABLE ' || quote_ident(tc.table_schema) || '.' || quote_ident(tc.table_name) ||
       ' DROP CONSTRAINT ' || quote_ident(tc.constraint_name) || ';'
FROM information_schema.table_constraints tc
WHERE tc.constraint_type IN ('PRIMARY KEY','UNIQUE','FOREIGN KEY')
  AND tc.table_schema = 'SCHEMA_NAME';" | psql -U postgres -d mpay_db
```

### 7.3 Drop Indexes

```bash
psql -U postgres -d mpay_db -At -c "
SELECT 'DROP INDEX IF EXISTS ' || quote_ident(schemaname) || '.' || quote_ident(indexname) || ';'
FROM pg_indexes
WHERE schemaname = 'SCHEMA_NAME';" | psql -U postgres -d mpay_db
```

---

## 8. Validation / QA Checks

### 8.1 Table Count

**Oracle:**

```sql
SELECT COUNT(*) AS table_count FROM user_tables;
```

**PostgreSQL:**

```sql
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'SCHEMA_NAME' AND table_type = 'BASE TABLE';
```

### 8.2 Sequence Count

**Oracle:**

```sql
SELECT COUNT(*) FROM user_sequences;
```

**PostgreSQL:**

```sql
SELECT COUNT(*) FROM information_schema.sequences
WHERE sequence_schema = 'SCHEMA_NAME';
```

### 8.3 Index Count

**Oracle:**

```sql
SELECT COUNT(*) AS index_count FROM user_indexes;
```

**PostgreSQL:**

```sql
SELECT COUNT(*) AS index_count FROM pg_indexes
WHERE schemaname = 'SCHEMA_NAME';
```

### 8.4 Constraint Validation

**Oracle:**

```sql
SELECT constraint_type, COUNT(*) FROM user_constraints
GROUP BY constraint_type ORDER BY constraint_type;
```

**PostgreSQL:**

```sql
SELECT constraint_type, COUNT(*) FROM information_schema.table_constraints
WHERE table_schema = 'SCHEMA_NAME'
GROUP BY constraint_type ORDER BY constraint_type;
```

### 8.5 Row Count Check

**Oracle:**

```sql
SELECT table_name, 
       TO_NUMBER(EXTRACTVALUE(
         XMLTYPE(dbms_xmlgen.getxml('select count(*) c from '||owner||'.'||table_name)),
         '/ROWSET/ROW/C'
       )) AS count
FROM all_tables
WHERE owner = 'SCHEMA_NAME'
ORDER BY count DESC;
```

**PostgreSQL:**

```sql
WITH tbl AS (
  SELECT table_schema, table_name
  FROM   information_schema.tables
  WHERE  table_name NOT LIKE 'pg_%'
    AND  table_schema IN ('SCHEMA_NAME')
)
SELECT  table_schema AS schema_name,
        table_name,
        (xpath('/row/c/text()', query_to_xml(
          format('SELECT count(*) AS c FROM %I.%I', table_schema, table_name),
          FALSE, TRUE, ''
        )))[1]::text::int AS records_count
FROM    tbl
ORDER   BY records_count DESC;
```

---

## 9. Operational Notes

- **Run MPAY and PPS migrations independently** with their respective `ora2pg-*.conf` files.  
- **Keep logs** for all `expdp`, `impdp`, `ora2pg`, and `psql` operations for auditing and rollback.  
- **Apply cleansing and patches** (type fixes, `z_org_id` updates, deadlock fixes) before enabling full foreign keys in PostgreSQL.  
- **Use recovery utilities** (constraint/index drops) only when you need to re‑import or partially recover a schema.  
- **Always re‑run the QA checks** after each major import or patch cycle.
