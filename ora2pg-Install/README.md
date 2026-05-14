# ora2pg

##### POC for migration oracle DB to postgres using ora2pg

🚀 Step 1: run any database , on our case we use oracle docker with version 12c which use Centos 7 :

```
docker run -d -p 1521:1521 -v /u01/app/oracle:/u01/app/oracle progressoft/oracle:db-12c-ee
```

- You need to enable to update Centos repo for this docker image OS to be able to install any pkgs and to avoid below error :

```
Cannot find a valid baseurl for repo: base/7/x86_64
ChatGPT said:

Ah, that error typically means the CentOS 7 base repository is no longer accessible, which is true since CentOS 7 reached End of Life (EOL) on June 30, 2024. As a result, the default base URL is broken or removed from official mirrors.
```

###### How to Fix: Cannot find a valid baseurl for repo: base/7/x86_64

- Switch to Vault Mirror (Recommended for EOL CentOS 7)

- Edit your repo files to point to the CentOS Vault, which archives older versions.

```
 vi /etc/yum.repos.d/CentOS-Base.repo
```

Replace mirror URLs with vault:

Change this:

```
mirrorlist=http://mirrorlist.centos.org/...
```

To This:

```
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
```

Do the same for [updates] and [extras] sections:

- The file must be look as below [Final]:


```
 [base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-$releasever - Updates
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/updates/$basearch/
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/extras/$basearch/
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra
#baseurl=http://mirror.centos.org/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
```


🚀 Step 2: Install Required Packages 

```
sudo yum -y install perl perl-devel perl-CPAN make gcc libaio libaio-devel unzip wget git epel-release
sudo yum -y install perl-DBD-Pg
```

   🚀  Optional (if the tool is not installed on the DB server):

       Download and extract the Oracle Instant Client on a separate server. 

Download these from: Oracle Instant Client Downloads https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html

  1. https://download.oracle.com/otn_software/linux/instantclient/1926000/instantclient-basic-linux.x64-19.26.0.0.0dbru.zip
  2. https://download.oracle.com/otn_software/linux/instantclient/1926000/instantclient-sdk-linux.x64-19.26.0.0.0dbru.zip 

Assume you've saved them to /tmp:

```
# Assuming you downloaded zip files into ~/Downloads
cd ~/Downloads
sudo mkdir -p /opt/oracle
sudo unzip instantclient-basic-linux.x64-19.26.0.0.0dbru.zip -d /opt/oracle
sudo unzip instantclient-sdk-linux.x64-19.26.0.0.0dbru.zip  -d /opt/oracle

# Create symbolic link
cd /opt/oracle/instantclient_*
sudo ln -s libclntsh.so.* libclntsh.so
sudo ln -s libocci.so.* libocci.so

# Set environment variables
echo "export LD_LIBRARY_PATH=/opt/oracle/instantclient_19.26" >> ~/.bashrc
echo "export ORACLE_HOME=/opt/oracle/instantclient_19.26" >> ~/.bashrc
```

🌐 Set Environment Variables

Add this to your ~/.bashrc (or export manually):

```
export ORACLE_HOME=/opt/oracle/instantclient
export LD_LIBRARY_PATH=$ORACLE_HOME
export PATH=$ORACLE_HOME:$PATH
```

Then activate it:

```
source ~/.bashrc
```

Check the .so files:

```
cd $ORACLE_HOME
ls libclntsh.so*
```

If needed, create symlinks:

```
sudo ln -s libclntsh.so.21.1 libclntsh.so
sudo ln -s libocci.so.21.1 libocci.so
```





🚀 Step 3: Update bash profile 

```
export LD_LIBRARY_PATH=$ORACLE_HOME/lib 
```

and make sure that ORACLE_HOME exported.

and add these export into bash profie to avoid export it manaully everytime.

🚀 Step 4: Install DBD::Oracle

Now install the Perl Oracle driver:

```
cd ~
curl -LO https://cpan.metacpan.org/authors/id/Z/ZA/ZARQUON/DBD-Oracle-1.90.tar.gz
tar xzf DBD-Oracle-1.90.tar.gz
cd DBD-Oracle-1.90

perl Makefile.PL
make
make test
sudo make install

```

Test it:

```
perl -MDBD::Oracle -e 'print "DBD::Oracle OK\n"'
```

The output must be :

```
DBD::Oracle OK
```

🚀 Step 5: Install ora2pg

Latest from GitHub

```
git clone https://github.com/darold/ora2pg.git
cd ora2pg
perl Makefile.PL
make
sudo make install
ora2pg -t SHOW_VERSION
```


🚀 Step 6: Create a POC Config


```
ora2pg --project_base_dir ~/ora2pg_poc --init_project test_migration
cd ~/test_migration/config

```

cd /root/DBD-Oracle-1.90/ora2pg/test_migration/config

##### Edit ora2pg.conf:

```
# Set the Oracle home directory
ORACLE_HOME     /u01/app/oracle/product/12.2.0/EE

# Set Oracle database connection (datasource, user, password)
ORACLE_DSN      dbi:Oracle:host=localhost;sid=EE;port=1521
ORACLE_USER     system
ORACLE_PWD      oracle

# Set this to 1 if you connect as simple user and can not extract things
# from the DBA_... tables. It will use tables ALL_... This will not works
# with GRANT export, you should use an Oracle DBA username at ORACLE_USER
USER_GRANTS     1

# Trace all to stderr
DEBUG           0

# This directive can be used to send an initial command to Oracle, just after
# the connection. For example to unlock a policy before reading objects or
# to set some session parameters. This directive can be used multiple time.
#ORA_INITIAL_COMMAND


#------------------------------------------------------------------------------
# SCHEMA SECTION (Oracle schema to export and use of schema in PostgreSQL)
#------------------------------------------------------------------------------

# Export Oracle schema to PostgreSQL schema
EXPORT_SCHEMA   0

# Oracle schema/owner to use
SCHEMA AWAD
```


🚀 Step 7: create sample schema with data :

```
create user awad identified by awad;
grant dba to awad;
conn awad/awad

-- Create a table: Departments
CREATE TABLE departments (
    dept_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    dept_name VARCHAR2(100) NOT NULL UNIQUE,
    location VARCHAR2(100),
    CONSTRAINT chk_dept_name CHECK (LENGTH(dept_name) > 1)
);

-- Create a table: Employees
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(150) UNIQUE,
    salary NUMBER(10,2) CHECK (salary >= 0),
    hire_date DATE DEFAULT SYSDATE,
    dept_id NUMBER,
    CONSTRAINT fk_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Create an index on salary
CREATE INDEX idx_salary ON employees(salary);

-- Create a sequence for employee IDs
CREATE SEQUENCE emp_seq
  START WITH 1000
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

-- Insert sample departments
INSERT INTO departments (dept_name, location) VALUES ('IT', 'New York');
INSERT INTO departments (dept_name, location) VALUES ('HR', 'London');

-- Insert sample employees
INSERT INTO employees (emp_id, emp_name, email, salary, dept_id)
VALUES (emp_seq.NEXTVAL, 'Alice Johnson', 'alice@example.com', 6000, 1);

INSERT INTO employees (emp_id, emp_name, email, salary, dept_id)
VALUES (emp_seq.NEXTVAL, 'Bob Smith', 'bob@example.com', 5000, 2);

-- Create a function: calculate annual salary
CREATE OR REPLACE FUNCTION get_annual_salary(p_emp_id IN NUMBER) RETURN NUMBER IS
  v_salary NUMBER;
BEGIN
  SELECT salary * 12 INTO v_salary FROM employees WHERE emp_id = p_emp_id;
  RETURN v_salary;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END;
/

-- Create a procedure: give a raise
CREATE OR REPLACE PROCEDURE give_raise(p_emp_id IN NUMBER, p_percent IN NUMBER) IS
BEGIN
  UPDATE employees
  SET salary = salary + (salary * p_percent / 100)
  WHERE emp_id = p_emp_id;
END;
/

-- Create a trigger: auto-assign next emp_id on insert
CREATE OR REPLACE TRIGGER trg_emp_id
BEFORE INSERT ON employees
FOR EACH ROW
WHEN (NEW.emp_id IS NULL)
BEGIN
  SELECT emp_seq.NEXTVAL INTO :NEW.emp_id FROM dual;
END;
/

-- Create a view: employee summary
CREATE OR REPLACE VIEW emp_summary AS
SELECT e.emp_id, e.emp_name, d.dept_name, e.salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;
```


🚀 Step 8: Run a Test Export

```
export LD_LIBRARY_PATH=$ORACLE_HOME/lib 
```


```
root@9f684404b1ab config]# ora2pg -c ora2pg.conf -t TABLE -o tables.sql
DBD::Oracle::dr connect warning: ORA-28002: the password will expire within 7 days (DBD SUCCESS_WITH_INFO: OCISessionBegin) at /usr/lib64/perl5/vendor_perl/DBI.pm line 670.
[2025-04-09 07:09:20] [========================>] 3/3 tables (100.0%) end of scanning.         
[2025-04-09 07:09:41] [========================>] 3/3 tables (100.0%) end of table export.
[root@9f684404b1ab config]# ls -lrt
total 92
-rw-r--r-- 1 root root 71819 Apr  9 06:36 ora2pg.conf
-rw-r--r-- 1 root root   647 Apr  9 07:09 tables.sql
-rw-r--r-- 1 root root   295 Apr  9 07:09 INDEXES_tables.sql
-rw-r--r-- 1 root root   403 Apr  9 07:09 FKEYS_tables.sql
-rw-r--r-- 1 root root   769 Apr  9 07:09 CONSTRAINTS_tables.sql
-rw-r--r-- 1 root root  1211 Apr  9 07:09 AUTOINCREMENT_tables.sql
[root@9f684404b1ab config]# cat tables.sql 
-- Generated by Ora2Pg, the Oracle database Schema converter, version 24.3
-- Copyright 2000-2024 Gilles DAROLD. All rights reserved.
-- DATASOURCE: dbi:Oracle:host=localhost;sid=EE;port=1521

SET client_encoding TO 'UTF8';

\set ON_ERROR_STOP ON



CREATE TABLE departments (
	dept_id bigint GENERATED BY DEFAULT AS IDENTITY,
	dept_name varchar(100) NOT NULL,
	location varchar(100)
) ;


CREATE TABLE employees (
	emp_id bigint NOT NULL,
	emp_name varchar(100) NOT NULL,
	email varchar(150),
	salary decimal(10,2),
	hire_date timestamp(0) DEFAULT statement_timestamp(),
	dept_id bigint
) ;


CREATE TABLE t1 (
	id bigint,
	name varchar(200)
) ;
[root@9f684404b1ab config]# ls
AUTOINCREMENT_tables.sql  CONSTRAINTS_tables.sql  FKEYS_tables.sql  INDEXES_tables.sql  ora2pg.conf  tables.sql
[root@9f684404b1ab config]# cat CONSTRAINTS_tables.sql
-- Generated by Ora2Pg, the Oracle database Schema converter, version 24.3
-- Copyright 2000-2024 Gilles DAROLD. All rights reserved.
-- DATASOURCE: dbi:Oracle:host=localhost;sid=EE;port=1521

SET client_encoding TO 'UTF8';

\set ON_ERROR_STOP ON

ALTER TABLE departments ADD PRIMARY KEY (dept_id);
ALTER TABLE departments ADD UNIQUE (dept_name);
ALTER TABLE departments ADD CONSTRAINT chk_dept_name CHECK (LENGTH(dept_name) > 2);
ALTER TABLE departments ALTER COLUMN dept_id SET NOT NULL;
ALTER TABLE departments ALTER COLUMN dept_name SET NOT NULL;
ALTER TABLE employees ADD PRIMARY KEY (emp_id);
ALTER TABLE employees ADD UNIQUE (email);
ALTER TABLE employees ALTER COLUMN emp_name SET NOT NULL;
ALTER TABLE employees ADD CONSTRAINT sys_c007356 CHECK (salary >= 0);
[root@9f684404b1ab config]# cat AUTOINCREMENT_tables.sql
-- Generated by Ora2Pg, the Oracle database Schema converter, version 24.3
-- Copyright 2000-2024 Gilles DAROLD. All rights reserved.
-- DATASOURCE: dbi:Oracle:host=localhost;sid=EE;port=1521

SET client_encoding TO 'UTF8';

\set ON_ERROR_STOP ON


CREATE OR REPLACE FUNCTION ora2pg_upd_autoincrement_seq (tbname text, colname text) RETURNS VOID AS $body$
DECLARE
        query text;
        maxval bigint;
        seqname text;
BEGIN
        query := 'SELECT max(' || colname || ')+1 FROM ' || tbname || '';
        EXECUTE query INTO maxval;
        IF (maxval IS NOT NULL) THEN
		query := $$SELECT pg_get_serial_sequence ('$$|| tbname || $$', '$$ || colname || $$');$$;
                EXECUTE query INTO seqname;
                IF (seqname IS NOT NULL) THEN
                        query := 'ALTER SEQUENCE ' || seqname || ' RESTART WITH ' || maxval;
                        EXECUTE query;
                END IF;
        ELSE
                RAISE NOTICE 'Table % is empty, you must load the AUTOINCREMENT file after data import.', tbname;
        END IF;
END;
$body$
LANGUAGE PLPGSQL;

SELECT ora2pg_upd_autoincrement_seq('departments','dept_id');
DROP FUNCTION ora2pg_upd_autoincrement_seq(text, text);
[root@9f684404b1ab config]# ls -lrt
total 92
-rw-r--r-- 1 root root 71819 Apr  9 06:36 ora2pg.conf
-rw-r--r-- 1 root root   647 Apr  9 07:09 tables.sql
-rw-r--r-- 1 root root   295 Apr  9 07:09 INDEXES_tables.sql
-rw-r--r-- 1 root root   403 Apr  9 07:09 FKEYS_tables.sql
-rw-r--r-- 1 root root   769 Apr  9 07:09 CONSTRAINTS_tables.sql
-rw-r--r-- 1 root root  1211 Apr  9 07:09 AUTOINCREMENT_tables.sql
[root@9f684404b1ab config]# cat FKEYS_tables.sql
-- Generated by Ora2Pg, the Oracle database Schema converter, version 24.3
-- Copyright 2000-2024 Gilles DAROLD. All rights reserved.
-- DATASOURCE: dbi:Oracle:host=localhost;sid=EE;port=1521

SET client_encoding TO 'UTF8';

\set ON_ERROR_STOP ON

ALTER TABLE employees ADD CONSTRAINT fk_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE NO ACTION NOT DEFERRABLE INITIALLY IMMEDIATE;
[root@9f684404b1ab config]# cat INDEXES_tables.sql
-- Generated by Ora2Pg, the Oracle database Schema converter, version 24.3
-- Copyright 2000-2024 Gilles DAROLD. All rights reserved.
-- DATASOURCE: dbi:Oracle:host=localhost;sid=EE;port=1521

SET client_encoding TO 'UTF8';

\set ON_ERROR_STOP ON

CREATE INDEX idx_salary ON employees (salary);
[root@9f684404b1ab config]# 

```


🚀 Step 9: Test script on postgres it must working : 

```
migration=# SET client_encoding TO 'UTF8';
SET
migration=# \set ON_ERROR_STOP ON
migration=# CREATE TABLE departments (
        dept_id bigint GENERATED BY DEFAULT AS IDENTITY,
        dept_name varchar(100) NOT NULL,
        location varchar(100)
) ;
CREATE TABLE
migration=# CREATE TABLE employees (
        emp_id bigint NOT NULL,
        emp_name varchar(100) NOT NULL,
        email varchar(150),
        salary decimal(10,2),
        hire_date timestamp(0) DEFAULT statement_timestamp(),
        dept_id bigint
) ;
CREATE TABLE
migration=# CREATE TABLE t1 (
        id bigint,
        name varchar(200)
) ;
CREATE TABLE
migration=# ALTER TABLE departments ADD PRIMARY KEY (dept_id);
ALTER TABLE departments ADD UNIQUE (dept_name);
ALTER TABLE departments ADD CONSTRAINT chk_dept_name CHECK (LENGTH(dept_name) > 2);
ALTER TABLE departments ALTER COLUMN dept_id SET NOT NULL;
ALTER TABLE departments ALTER COLUMN dept_name SET NOT NULL;
ALTER TABLE employees ADD PRIMARY KEY (emp_id);
ALTER TABLE employees ADD UNIQUE (email);
ALTER TABLE employees ALTER COLUMN emp_name SET NOT NULL;
ALTER TABLE employees ADD CONSTRAINT sys_c007356 CHECK (salary >= 0);
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
migration=# ALTER TABLE employees ADD CONSTRAINT fk_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE NO ACTION NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE
migration=# CREATE OR REPLACE FUNCTION ora2pg_upd_autoincrement_seq (tbname text, colname text) RETURNS VOID AS $body$
DECLARE
        query text;
        maxval bigint;
        seqname text;
BEGIN
        query := 'SELECT max(' || colname || ')+1 FROM ' || tbname || '';
        EXECUTE query INTO maxval;
        IF (maxval IS NOT NULL) THEN
                query := $$SELECT pg_get_serial_sequence ('$$|| tbname || $$', '$$ || colname || $$');$$;
                EXECUTE query INTO seqname;
                IF (seqname IS NOT NULL) THEN
                        query := 'ALTER SEQUENCE ' || seqname || ' RESTART WITH ' || maxval;
                        EXECUTE query;
                END IF;
        ELSE
                RAISE NOTICE 'Table % is empty, you must load the AUTOINCREMENT file after data import.', tbname;
        END IF;
END;
$body$
LANGUAGE PLPGSQL;
CREATE FUNCTION
migration=# SELECT ora2pg_upd_autoincrement_seq('departments','dept_id');
DROP FUNCTION ora2pg_upd_autoincrement_seq(text, text);
NOTICE:  Table departments is empty, you must load the AUTOINCREMENT file after data import.
 ora2pg_upd_autoincrement_seq 
------------------------------
 
(1 row)

DROP FUNCTION
migration=# CREATE INDEX idx_salary ON employees (salary);
CREATE INDEX
```