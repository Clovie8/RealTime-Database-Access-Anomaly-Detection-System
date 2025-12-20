Design Decisions (ADR)

This document records the architectural decisions made during the development of the Security Anomaly Detection System.

Decision 1: Use of PL/SQL Triggers for Security

Status: Accepted

Context: We needed to ensure security rules apply to all users, regardless of whether they access data via a Web App, Python script, or SQL Developer.

Decision: Implement security logic in Database Triggers (AFTER LOGON, BEFORE UPDATE).

Consequences:

(+) Positive: Impossible to bypass. Security is tight to the data.

(-) Negative: Slight overhead on connection time (~10-20ms).

Decision 2: Autonomous Transactions for Alerting

Status: Accepted

Context: When a security violation occurs, the system raises an Exception to block the user. In Oracle, raising an exception typically rolls back the entire transaction, which would result in the "Alert Log" insertion also being lost.

Decision: Use PRAGMA AUTONOMOUS_TRANSACTION for the sp_log_security_alert procedure.

Consequences:

(+) Positive: The Alert is committed permanently, even if the user's malicious action is rolled back.

(-) Negative: Care must be taken to avoid deadlocks (though low risk for Insert-only logging).

Decision 3: Compound Triggers for Auditing

Status: Accepted

Context: We required auditing of the "Old" vs "New" values during updates. Using separate triggers can lead to "Mutating Table" errors or complex state management.

Decision: Use a Compound Trigger (FOR INSERT OR UPDATE OR DELETE).

Consequences:

(+) Positive: Variables can share state between the triggering statement and the row-level execution. Efficiently handles all DML types in one block.

(-) Negative: Slightly more complex syntax than simple triggers.

Decision 4: Use of Window Functions for Analytics

Status: Accepted

Context: We needed to detect complex patterns like "Brute Force" (multiple failures in short time) and "Impossible Travel" (logins from different IPs quickly).

Decision: Use SQL Window Functions (LAG, LEAD, ROW_NUMBER, OVER PARTITION BY) inside Views.

Consequences:

(+) Positive: Extremely fast calculation performed by the DB kernel. Avoids complex and slow self-joins. Real-time analysis capability.

Decision 5: Bulk Processing for Maintenance

Status: Accepted

Context: The log tables (ACCESS_LOG) will grow rapidly. Deleting old rows one by one causes context switching and redo-log churn.

Decision: Use BULK COLLECT and FORALL in the maintenance package.

Consequences:

(+) Positive: Reduces context switching between SQL and PL/SQL engines by ~95%. significant performance gain during cleanup jobs.