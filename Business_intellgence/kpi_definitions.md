Key Performance Indicator (KPI) Definitions

These metrics define the success and efficiency of the Security Anomaly Detection System.

KPI 1: Threat Interception Rate (TIR)

Definition: The percentage of login or DML attempts that were actively blocked by the system compared to total attempts.

Business Goal: Detect 100% of unauthorized attempts. A high rate indicates an active attack; a low rate indicates normal operations.

Calculation:

(Count of SECURITY_ALERTS / (Count of ACCESS_LOG + Count of SECURITY_ALERTS)) * 100


KPI 2: Mean Time Between Incidents (MTBI)

Definition: The average time elapsed between two critical security alerts (e.g., Brute Force detections).

Business Goal: We want this number to increase over time, indicating a more stable and secure environment.

Calculation:

AVG(Time_Difference(Alert_N, Alert_N-1))


KPI 3: Peak Attack Hour

Definition: The specific hour of the day (00:00 - 23:00) that experiences the highest volume of Failed login attempts or blocked DMLs.

Business Goal: Used to schedule DBA shifts. If Peak Attack Hour is 03:00 AM, automated monitoring must be prioritized during that window.

Calculation:

SELECT TO_CHAR(alert_time, 'HH24') FROM SECURITY_ALERTS GROUP BY... ORDER BY COUNT DESC (Limit 1)


KPI 4: Privilege Abuse Count (Insider Threat)

Definition: The number of times an authorized internal user (not an unknown IP) attempted an action they are not permitted to do (e.g., a Finance Manager trying to Delete logs).

Business Goal: Value should be 0. Any positive number triggers a mandatory HR or Security training review.

Context: Distinguished from external attacks by filtering for known usernames in APP_USERS.