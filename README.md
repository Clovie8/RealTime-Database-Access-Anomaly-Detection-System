# Real-time Database Access Anomaly Detection System

### Final Practicum Project – PL/SQL

### Student Name: DUKUNDIMANA Clovis

### Student ID: 27122
___


#### Project Overview

This project implements a "Zero Trust" security layer directly within the Oracle Database using advanced PL/SQL. It moves beyond standard password authentication to enforce context-aware security policies, restricting access based on Time of **Day, IP Address** and **Calendar Events** (Weekends/Holidays).

#### Problem Statement

Traditional database security relies heavily on static passwords, leaving systems vulnerable to credential theft and insider threats. Once a user logs in, they often have unchecked access to sensitive data regardless of when or where they are connecting from, making it difficult to detect anomalies until a breach has already occurred.

#### Key Objectives:

- **Context-Aware Authorization:** Implement functions to validate logins against strict "Business Hour" and "IP Whitelist" rules.

- **Automated Anomaly Detection:** Use triggers and autonomous transactions to instantly log suspicious behavior without disrupting the main transaction.

- **Strict DML Governance:** Enforce a "No Change" policy on Weekdays and Public Holidays using Simple Triggers.

- **Comprehensive Auditing:** Implement Compound Triggers to capture granular "Before vs. After" snapshots of all data changes.
  

#### Quick Start Instructions

Follow these steps to deploy the system in order.

1: **Database & User Setup** 

*Run as PDB Administrator (SYS/SYSTEM)*

    Execute Phase4_DB_Creation/oracle_setup.sql to create the SEC_DATA tablespace and the SEC_ADMIN user.

2: **Schema Build & Data Load**

*Run as SEC_ADMIN*

    Execute Phase5_Tables/1_ddl_schema.sql to build the 5 core tables.

    Execute Phase5_Tables/2_dml_data_insertion.sql to generate 600+ realistic test logs.

3: **Deploy PL/SQL Logic (Phase VI)**

*Run as SEC_ADMIN*

    Execute Phase6_Logic/1_functions.sql (Standalone Functions).

    Execute Phase6_Logic/2_procedures.sql (Standalone Procedures).

    Execute Phase6_Logic/3_package_maintenance.sql (Maintenance Package).

    Execute Phase6_Logic/4_window_functions.sql (Analytics View).

4: **Activate Security Triggers (Phase VII)**

*Run as SEC_ADMIN*

    Execute Phase7_Auditing/1_setup_tables.sql (Holiday & Audit tables).

    Execute Phase7_Auditing/2_business_logic.sql (Restriction Logic).

    Execute Phase7_Auditing/3_triggers.sql (Simple & Compound Triggers).
<br>

#### Documentation

Detailed technical documentation is available in the documentation/ folder:

- **Data Dictionary:** Detailed breakdown of schemas (APP_USERS, SECURITY_ALERTS, etc.) and constraints.

- **System Architecture:** High-level overview of the Trigger-Logic-Data layers.

- **Design Decisions (ADR):** Explanation of why specific technologies (Compound Triggers, Bulk Collect) were chosen. 
<br>

#### Testing & Validation

Testing scripts are provided in each phase folder. To verify the system status, run:

- Phase6_Logic/5_testing_script.sql

- Phase7_Auditing/4_testing_phase_vii.sql
