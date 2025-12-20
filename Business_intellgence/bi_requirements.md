# Business Intelligence Requirements

**Project:** Real-time Database Access Anomaly Detection  
**Phase:** Part B (BI & Analytics)

---

## 1. Decision Support Needs
The BI layer must transform raw security logs into actionable insights to support the following decisions:

* **Risk Mitigation:** Determine if current security policies (Time/IP rules) are too strict (blocking valid work) or too loose (allowing attacks).
* **Resource Allocation:** Decide when to schedule DBA monitoring shifts based on "Peak Attack Hours."
* **Compliance Verification:** Provide evidence to external auditors that the "Zero Trust" model is actively blocking unauthorized DML.
* **Insider Threat Detection:** Identify internal users who frequently attempt actions outside their permission scope (e.g., Weekend updates).

---

## 2. Stakeholder Analysis

| Stakeholder | Role | Information Need | Reporting Frequency |
| :--- | :--- | :--- | :--- |
| **CISO (Chief Info Security Officer)** | Strategic | High-level risk posture (Red/Green status), MTBI trends, and budget justification data. | Weekly (Executive Summary) |
| **SecOps / SOC Team** | Operational | Real-time alerts, IP blacklisting candidates, and attack vector analysis. | Real-Time (Live Dashboard) |
| **Database Administrators (DBA)** | Technical | System performance impact, storage growth of log tables, and false-positive rates. | Daily (Performance View) |
| **Compliance Auditors** | External | Immutable history of changes to `SENSITIVE_TABLE_CONFIG` and proof of enforcement. | Monthly/Quarterly (Audit Dump) |

---

## 3. Reporting Specifications

* **Data Source:** Oracle PDB (`SECURITY_ALERTS`, `ACCESS_LOG`, `AUDIT_HISTORY`).
* **Tooling:** Power BI (connected via Oracle Client) or Oracle APEX.
* **Latency:**
    * **Operational Dashboards:** < 5 minutes latency.
    * **Strategic Reports:** Daily aggregation.
