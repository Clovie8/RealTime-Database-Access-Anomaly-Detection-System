-- This script should be run after logging into the target Pluggable Database (PDB)

CREATE PLUGGABLE DATABASE Thu_27122_clovis_DBAccessAD_db
ADMIN USER Clovis_admin IDENTIFIED BY clovis
ROLES = (DBA)
FILE_NAME_CONVERT = (
'C:\app\pc\product\21c\oradata\XE\pdbseed\', 
'C:\app\pc\product\21c\oradata\XE\Thu_27122_Clovis_DBAccessAD_db\'
);

ALTER PLUGGABLE DATABASE Thu_27122_Clovis_DBAccessAD_db OPEN READ WRITE;


ALTER PLUGGABLE DATABASE Thu_27122_Clovis_DBAccessAD_db SAVE STATE;

--------------------------------------------------------------------------------
-- 1. TABLESAPCE CONFIGURATION
--------------------------------------------------------------------------------

-- A. Data Tablespace for application data (SECURITY_ALERTS, ACCESS_LOG)
CREATE TABLESPACE SEC_DATA DATAFILE 
    'sec_data01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    LOGGING
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

-- B. Index Tablespace for primary/foreign key indexes
CREATE TABLESPACE SEC_IDX DATAFILE 
    'sec_idx01.dbf' SIZE 50M AUTOEXTEND ON NEXT 5M MAXSIZE UNLIMITED
    LOGGING
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

-- C. Dedicated Temporary Tablespace (often shared by default, but good practice to define)
CREATE TEMPORARY TABLESPACE SEC_TEMP TEMPFILE 
    'sec_temp01.dbf' SIZE 20M AUTOEXTEND ON NEXT 2M MAXSIZE 100M;

-- Note on Archive Logging: Archive logging is a database-level configuration (CDB/PDB).
-- Assuming the PDB (or the parent CDB) is already in ARCHIVELOG mode:
-- ALTER DATABASE ARCHIVELOG; (Requires startup/shutdown and is typically done at the CDB level)

--------------------------------------------------------------------------------
-- 2. MEMORY PARAMETER CONFIGURATION (via Resource Manager)
--------------------------------------------------------------------------------
-- In modern Oracle, memory parameters (SGA/PGA) are typically managed by Automatic
-- Memory Management (AMM) or Automatic Shared Memory Management (ASMM) at the 
-- CDB level. We ensure our new user's session doesn't consume excessive resources.

-- Create a profile to limit excessive session resource consumption
CREATE PROFILE SEC_ADMIN_PROFILE LIMIT
    CPU_PER_CALL 3000000 -- 50 minutes (3,000,000 centiseconds)
    SESSIONS_PER_USER UNLIMITED
    CONNECT_TIME UNLIMITED
    IDLE_TIME 60;

--------------------------------------------------------------------------------
-- 3. ADMIN USER SETUP AND PRIVILEGES
--------------------------------------------------------------------------------

-- Create the Super Admin User
CREATE USER SEC_ADMIN IDENTIFIED BY "MySecretP@ssw0rd" -- Replace with your first name
    DEFAULT TABLESPACE SEC_DATA
    TEMPORARY TABLESPACE SEC_TEMP
    PROFILE SEC_ADMIN_PROFILE
    ACCOUNT UNLOCK;

-- Grant required super admin privileges
GRANT CONNECT, RESOURCE, DBA TO SEC_ADMIN;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER TO SEC_ADMIN;

-- Grant unlimited quota on the application tablespaces
ALTER USER SEC_ADMIN QUOTA UNLIMITED ON SEC_DATA;
ALTER USER SEC_ADMIN QUOTA UNLIMITED ON SEC_IDX;

-- Commit changes
COMMIT;
