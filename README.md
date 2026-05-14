
# Dinarak Oracle to PostgreSQL Migration Guide

This guide provides a practical roadmap for migrating the Dinarak database from Oracle to PostgreSQL. It is based on hands-on experience. Each step below is aimed at minimizing migration errors and ensuring a functional PostgreSQL-based environment for the Dinarak application.

---

## 1. Prepare Oracle Environment and Ora2Pg Tool

### a. Set Up Oracle in Docker
You will need an Oracle Docker image (e.g., `oracle:19.3.0-ee`). Set it up as follows:

```bash
docker run -d -p 1521:1521 \
  --name oracle_19c_image \
  -v /opt/oracle/oradata:/opt/oracle/oradata \
  oracle:19.3.0-ee
```

Import the Dinarak Oracle dump into this image using the `imp` tool. Make sure the database and schema are loaded correctly.

---

## 2. Configure Ora2Pg

Prepare the `ora2pg.conf` configuration file to include:

- Oracle connection strings
- Target PostgreSQL schema

you can use the attached `ora2pg.conf` file from the project repository.

---

## 3. Export Oracle Schema and Data

Use the following commands to extract schema objects and data using Ora2Pg:

```bash
ora2pg -c ora2pg.conf -t TABLE -o tables.sql | this will generate tables / CONSTRAINTS / FKs / Indexes
ora2pg -c ora2pg.conf -t SEQUENCE -o sequences.sql
ora2pg -c ora2pg.conf -t INSERT -o data.sql -b ./data  
```

This will generate SQL files to be executed on the PostgreSQL side.

---

## 4. Set Up PostgreSQL Environment

Create a PostgreSQL Docker container or use a managed database. Then, create the Dinarak schema and import the exported SQL files in the following order:

```bash
psql -U dinarak -d postgres -c "SET search_path TO dinarak;" -f tables.sql
psql -U dinarak -d postgres -c "SET search_path TO dinarak;" -f CONSTRAINTS.sql
psql -U dinarak -d postgres -c "SET search_path TO dinarak;" -f data.sql
psql -U dinarak -d postgres -c "SET search_path TO dinarak;" -f sequences.sql
```

---

## 5. Data Type Fixes Before Importing Foreign Keys

Before importing foreign key constraints, run a custom SQL patch file that corrects type mismatches such as `NUMBER(38)` to `bigint`.

use the attached file `fix-number-to-bigint.sql` change the schema name 

Once types are corrected, run:

```bash
psql -U dinarak -d postgres -c "SET search_path TO dinarak;" -f FK.sql
```

If you encounter errors related to foreign keys, drop all foreign keys with:

```bash
psql -U postgres -d postgres -At -c "
SELECT 'ALTER TABLE ' || tc.table_schema || '.' || tc.table_name || 
       ' DROP CONSTRAINT ' || tc.constraint_name || ';'
FROM information_schema.table_constraints AS tc
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'dinarak';" | psql -U postgres -d postgres
```


Optionally, import indexes with:

```bash
psql -U dinarak -d postgres -c "SET search_path TO dinarak;" -f indexes.sql
```

---

## 6. Convert Procedures to Functions

Ora2Pg does not automatically convert Oracle `PROCEDURE`s to PostgreSQL `FUNCTION`s. Use this tool:

https://sqlines.com/online

Some procedures may require manual fixes. Always replace `CREATE OR REPLACE PROCEDURE` with `CREATE OR REPLACE FUNCTION` and adjust OUT parameters to `RETURNS TABLE`.

Use this to get all `PROCEDURE`:
```SQL
SELECT DBMS_METADATA.GET_DDL('PROCEDURE', object_name, owner)
FROM all_procedures
WHERE owner = 'DINARAK'
  AND object_type = 'PROCEDURE';
```

Alternatively, copy functions from another PostgreSQL-based MPay client (e.g., MEPS).

---

## 7. Build Dinarak Application Artifacts for PostgreSQL

Create a new branch from the desired release tag. Then update the `Application.java` configuration to set:

```java
DBTypes.POSTGRESQL
```

Ensure your environment configuration points to the PostgreSQL JDBC driver and connection URL.

---

## 8. Resolve JFW UI Issues (Dropdowns)

Some dropdowns in the JFW application may fail due to expressions like:

```
isCustomer = 1
isSystem = 0
```

Update them using SQL to switch from numeric to boolean format:

```
isCustomer = true
isSystem = false
```

Apply SQL `UPDATE` statements to fix these values where necessary in `jfw_value_providers`.

```SQL
UPDATE jfw_value_providers
SET joinexpression = REGEXP_REPLACE(
    REGEXP_REPLACE(joinexpression, '\s*=\s*[''"]?0[''"]?', ' = false', 'gi'),
                      '\s*=\s*[''"]?1[''"]?', ' = true', 'gi'
);
```

---

## 9. Final Testing

Run full functional tests:

- Customer creation
- Corporate account management
- Cash-in/Cash-out flows
- View loading and logic execution

You may still face occasional type mismatches due to ora2pg limitations. Fix them case by case by examining schema differences and logs.

---

This guide provides a complete and proven path to getting the Dinarak backend migrated from Oracle to PostgreSQL.