# System Architecture
**System:** Database-Level Security & Anomaly Detection

---

## 1. High-Level Overview
The system operates as a **"Zero Trust"** layer embedded directly within the Oracle Database kernel. Unlike application-level security, which can be bypassed if a user connects directly to the DB via SQL Developer or ODBC, this system intercepts actions at the database trigger level.

---

## 2. Architectural Layers

### Layer 1: The Gatekeeper (Triggers)
* **Logon Trigger:** Fires immediately when a session is requested. It pauses the connection to validate context (Time/IP) before a session is fully established.
* **DML Guard Trigger (`trg_restrict_weekend_work`):** Fires **BEFORE** any Insert/Update/Delete on sensitive tables. It checks the "Weekend/Holiday" logic and acts as a firewall.
* **Audit Compound Trigger (`trg_audit_sensitive_config`):** Fires **FOR EACH ROW** to capture granular data changes without impacting performance.

### Layer 2: The Core Logic (PL/SQL)
#### Standalone Procedures & Functions:
* **`fn_is_work_permitted`:** Determines if the current date (Holiday/Weekend) allows DML.
* **`sp_log_security_alert`:** A dedicated "side-channel" (**Autonomous Transaction**) that commits security alerts even if the main user transaction fails.

#### Maintenance Package (`PKG_SEC_MAINTENANCE`):
* Handles bulk data operations to optimize storage and performance using `BULK COLLECT` and `FORALL`.

### Layer 3: The Data Vault (Schema)
* **Configuration Tables:** (`APP_USERS`, `ALLOWED_IPS`) define the security rules.
* **Log Tables:** (`SECURITY_ALERTS`, `AUDIT_HISTORY`) store immutable evidence for forensic analysis.

---

## 3. Data Flow Diagram

1.  **Event:** User initiates **LOGIN** or **UPDATE**.
2.  **Intercept:** Trigger captures the event payload (User, IP, Time, Data).
3.  **Process:**
    * Logic compares payload vs. `APP_USERS` config.
    * Logic checks `PUBLIC_HOLIDAYS`.
4.  **Decision:**
    * **Pass:** Allow transaction, log to `ACCESS_LOG`.
    * **Fail:** Raise `ORA-2000X` Exception, log to `SECURITY_ALERTS` (Autonomous).
5.  **Analytics:** Background views (`V_SEC_ANALYTICS_FULL`) aggregate logs into risk scores using **Window Functions**.

---

## 4. Security & Compliance Features
* **Immutable Logging:** Alerts are written via independent (Autonomous) transactions.
* **Separation of Duties:** The security schema (`SEC_ADMIN`) is distinct from standard application users.
* **Granular Auditing:** Captures "Before" and "After" values for forensic reconstruction via **Compound Triggers**.
