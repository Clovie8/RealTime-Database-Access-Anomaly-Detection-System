# Real-time Database Access Anomaly Detection System
**Final Practicum Project – PL/SQL**

**Student Name:** DUKUNDIMANA Clovis  
**Student ID:** 27122

---

## 📖 Project Overview
This project implements a **"Zero Trust"** security layer directly within the Oracle Database using advanced PL/SQL. It moves beyond standard password authentication to enforce context-aware security policies, restricting access based on **Time of Day**, **IP Address**, and **Calendar Events** (Weekends/Holidays).

---

## 🚩 Problem Statement
Traditional database security relies heavily on static passwords, leaving systems vulnerable to credential theft and insider threats. Once a user logs in, they often have unchecked access to sensitive data regardless of when or where they are connecting from, making it difficult to detect anomalies until a breach has already occurred.

---

## 🎯 Key Objectives
* **Context-Aware Authorization:** Implement functions to validate logins against strict "Business Hour" and "IP Whitelist" rules.
* **Automated Anomaly Detection:** Use triggers and autonomous transactions to instantly log suspicious behavior without disrupting the main transaction.
* **Strict DML Governance:** Enforce a "No Change" policy on Weekdays and Public Holidays using Simple Triggers.
* **Comprehensive Auditing:** Implement Compound Triggers to capture granular "Before vs. After" snapshots of all data changes.

---

## 🚀 Quick Start Instructions
Follow these steps to deploy the system in order.

### Step 1: Database & User Setup (Phase IV)
*Run as PDB Administrator (SYS/SYSTEM)*
1. Execute `Database/script/oracle_setup.sql` to create the `SEC_DATA` tablespace and the `SEC_ADMIN` user.

### Step 2: Schema Build & Data Load (Phase V)
*Run as SEC_ADMIN*
1. Execute `Database/script/Table Creation Script.sql` to build the 5 core tables.
2. Execute `Database/script/insert script.sql` to generate 600+ realistic test logs.

### Step 3: Deploy PL/SQL Logic (Phase VI)
*Run as SEC_ADMIN*
1. Execute `Database/script/Functions.sql` (Standalone Functions).
2. Execute `Database/script/Procedures.sql` (Standalone Procedures).
3. Execute `Database/script/Package Maintenance.sql` (Maintenance Package).
4. Execute `Database/script/Window Functions.sql` (Analytics View).

### Step 4: Activate Security Triggers (Phase VII)
*Run as SEC_ADMIN*
1. Execute `Database/script/Setup Tables.sql` (Holiday & Audit tables).
2. Execute `Database/script/Business Logic.sql` (Restriction Logic).
3. Execute `Database/script/Triggers.sql` (Simple & Compound Triggers).

---

## 📚 Documentation
Detailed technical documentation is available in the `documentation/` folder:
* **Data Dictionary:** Detailed breakdown of schemas (`APP_USERS`, `SECURITY_ALERTS`, etc.) and constraints.
* **System Architecture:** High-level overview of the Trigger-Logic-Data layers.
* **Design Decisions (ADR):** Explanation of why specific technologies (Compound Triggers, Bulk Collect) were chosen.

---

## 📊 Testing & Validation
Testing scripts are provided in each phase. To verify the system status, run:
* `Queries/Analytics_queries For (Database Interaction & Transactions).sql`
* `Queries/Audit_queries For (Advanced Programming & Auditing).sql`
* `Queries/Data_retrieval For (Table Implementation & Data Insertion).sql`
