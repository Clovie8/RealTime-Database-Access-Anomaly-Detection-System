# Oracle Database Creation and Configuration

This repository contains the necessary SQL scripts to create and configure the Oracle Pluggable Database (PDB) structure for the **Real-time Database Access Anomaly Detection** system.

---

## 1. Naming Convention
The database is configured under the following structure:
* **PDB Name:** `THU_27122_CLOVIS_DBACCESSAD_DB`
* **Application Schema/User:** `SEC_ADMIN`

---

## 2. Configuration Scripts Overview

| File | Purpose | Execution User |
| :--- | :--- | :--- |
| **oracle_setup.sql** | Creates tablespaces, temp tablespace, security profile, and the SEC_ADMIN user. | PDB Admin (or SYS) |
| **create_tables.sql** | Executes Data Definition Language (DDL) to create all 5 application tables and sequences. | SEC_ADMIN |

---

## 3. Database Configuration Details
The following configurations were implemented in `oracle_setup.sql`:

### Tablespaces
| Tablespace | Purpose | Size/Growth | Autoextend |
| :--- | :--- | :--- | :--- |
| **SEC_DATA** | Stores all application data (config, logs, and alerts). | 100MB initial, 10MB next | UNLIMITED |
| **SEC_IDX** | Stores all primary key, unique key, and foreign key indexes. | 50MB initial, 5MB next | UNLIMITED |
| **SEC_TEMP** | Dedicated temporary space for large sorts/joins. | 20MB initial, 2MB next | MAX 100MB |

### Admin User Setup
* **Username:** `SEC_ADMIN`
* **Password:** `clovis`
* **Default Tablespace:** `SEC_DATA`
* **Temporary Tablespace:** `SEC_TEMP`
* **Profile:** `SEC_ADMIN_PROFILE` (Limits CPU/call and idle time to prevent runaway queries)
* **Privileges:** DBA, CONNECT, RESOURCE, and specific rights (CREATE TABLE, CREATE PROCEDURE, etc.)

### Memory and Logging
* **Memory Parameters (SGA/PGA):** Managed by the `SEC_ADMIN_PROFILE` through session limits.
* **Archive Logging:** Assumed to be configured for `ARCHIVELOG` mode at the parent CDB level for full recoverability.

---

## 4. Project Structure Overview
```text
/Database
├── / Documentation
|   ├── README.md   <-- This document
└──/Scripts        <-- Contain All script used 
