BI Dashboard Design & Implementation Guide

This document outlines the visual layout, SQL data sources, and the step-by-step Power BI implementation guide for the project's dashboards.

Part 1: Design Specifications & SQL Sources

1. Executive Summary (Strategic View)

Target Audience: CISO / Management
Goal: At-a-glance view of the organization's security health.

Visual Layout:

KPI Cards: Current Threat Level, Total Threats, Block Rate.

Trend Chart: Line chart showing "Attacks per Day" (Last 30 days).

Attack Vector: Donut chart showing breakdown of ALERT_TYPE.

SQL Source Query:

SELECT 
    TRUNC(alert_time) as log_date,
    COUNT(*) as total_incidents,
    SUM(CASE WHEN alert_type = 'BRUTE_FORCE' THEN 1 ELSE 0 END) as critical_threats
FROM SECURITY_ALERTS
WHERE alert_time >= SYSDATE - 30
GROUP BY TRUNC(alert_time)
ORDER BY log_date DESC;


2. Audit Dashboard (Compliance View)

Target Audience: Auditors / Risk Managers
Goal: Detailed history of violations and configuration changes.

Visual Layout:

Violations Table: List of blocked DML attempts (Who, When, Details).

Slicers: Date Range, Username, Alert Type.

SQL Source Query:

SELECT 
    audit_id,
    table_name,
    operation,
    changed_by,
    old_value,
    new_value,
    change_timestamp
FROM AUDIT_HISTORY
ORDER BY change_timestamp DESC;


3. Performance Dashboard (Operational View)

Target Audience: DBAs
Goal: Monitor system load and user behavior patterns.

Visual Layout:

Peak Load Heatmap: Grid showing login volume by Hour vs. Day.

Success vs. Failure: Stacked bar chart.

SQL Source Query:

SELECT 
    TO_CHAR(logon_time, 'DY') as day_of_week,
    TO_CHAR(logon_time, 'HH24') as hour_of_day,
    COUNT(*) as connection_count
FROM ACCESS_LOG
GROUP BY TO_CHAR(logon_time, 'DY'), TO_CHAR(logon_time, 'HH24')
ORDER BY connection_count DESC;


Part 2: Power BI Implementation Guide

Follow these steps to recreate the dashboards from the raw database data.

Step 1: Data Extraction (CSV Method)

Export the raw data from Oracle SQL Developer to ensure clean connectivity.

Security Alerts: Run SELECT * FROM SECURITY_ALERTS; → Export to security_alerts.csv.

Access Logs: Run SELECT * FROM ACCESS_LOG; → Export to access_log.csv.

Audit History: Run SELECT * FROM AUDIT_HISTORY; → Export to audit_history.csv.

Step 2: Data Import & Modeling

Open Power BI Desktop.

Go to Get Data > Text/CSV. Load all three CSV files.

Verification: In "Data View", click on ALERT_TIME and LOGON_TIME columns. Ensure Data Type is set to Date/Time (not Text).

Step 3: DAX Measures (Intelligence)

Create the following measures in the SECURITY_ALERTS table to calculate KPIs dynamically.

Measure 1: Total Threats

Total Threats = COUNT(SECURITY_ALERTS[ALERT_ID])


Measure 2: Current Threat Level (Logic)

Threat Level = IF([Total Threats] > 10, "HIGH CRITICAL", "NORMAL")


Measure 3: Block Rate %

Block Rate = 
VAR TotalAccess = COUNT(ACCESS_LOG[LOG_ID])
VAR TotalBlocks = COUNT(SECURITY_ALERTS[ALERT_ID])
RETURN 
DIVIDE(TotalBlocks, (TotalAccess + TotalBlocks), 0)


Step 4: Visual Construction

Page 1: Executive Summary

KPI Cards: Use the Card visual. Drag Threat Level (Format as Red), Total Threats, and Block Rate into three separate cards.

Trend Chart: Use Line Chart.

X-Axis: ALERT_TIME (Day).

Y-Axis: Total Threats.

Attack Vectors: Use Donut Chart.

Legend: ALERT_TYPE.

Values: Total Threats.

Page 2: Audit & Compliance

Detailed Table: Use Table visual. Add columns: ALERT_TIME, USERNAME, ALERT_TYPE, ALERT_DETAILS.

Filters: Add a Slicer visual. Drag USERNAME into it to filter the table by specific users.

Page 3: Performance Matrix

Heatmap: Use Matrix visual.

Rows: LOGON_TIME (Day).

Columns: LOGON_STATUS.

Values: LOG_ID (Count).

Styling: Use Conditional Formatting on the Background Color to turn high-traffic cells Red.

Step 5: Final Polish

Go to the View tab.

Select the "Innovate" or "Storm" theme to apply a professional Dark Mode look suitable for a Security Operations Center (SOC) display.