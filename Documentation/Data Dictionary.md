Data Dictionary

Project: Real-time Database Access Anomaly Detection
Database: Oracle Pluggable Database (PDB)
Schema Owner: SEC_ADMIN

1. Core Configuration (Dimensions)

Table: APP_USERS

Master list of monitored database users and their behavior profiles.

Column Name

Data Type

Constraints

Description

USER_ID

NUMBER(10)

PK

Surrogate Primary Key (Sequence generated).

USERNAME

VARCHAR2(50)

UK, NOT NULL

Oracle DB Username. Links to logs/configs.

NORMAL_START_TIME

VARCHAR2(5)

NOT NULL

Start of allowed window (Format: 'HH24:MI').

NORMAL_END_TIME

VARCHAR2(5)

NOT NULL

End of allowed window (Format: 'HH24:MI').

ENFORCE_IP_WHITELIST

CHAR(1)

CHECK ('Y', 'N')

Flag to enable/disable IP address validation.

Table: ALLOWED_IPS

Whitelist of authorized IP addresses for users with strict security requirements.

Column Name

Data Type

Constraints

Description

IP_ID

NUMBER(10)

PK

Surrogate Primary Key.

USER_ID

NUMBER(10)

FK

Links to APP_USERS.USER_ID.

IP_ADDRESS

VARCHAR2(45)

NOT NULL

IPv4 or IPv6 address allowed for connection.

DESCRIPTION

VARCHAR2(100)



Context notes (e.g., 'VPN', 'Office HQ').

Table: SENSITIVE_TABLE_CONFIG

Permissions matrix defining who can perform DML on critical tables.

Column Name

Data Type

Constraints

Description

CONFIG_ID

NUMBER(10)

PK

Surrogate Primary Key.

TABLE_NAME

VARCHAR2(50)

NOT NULL

The target table being protected.

USERNAME

VARCHAR2(50)

FK

Links to APP_USERS.USERNAME.

CAN_INSERT

CHAR(1)

CHECK ('Y', 'N')

Authorization flag for INSERT operations.

CAN_UPDATE

CHAR(1)

CHECK ('Y', 'N')

Authorization flag for UPDATE operations.

CAN_DELETE

CHAR(1)

CHECK ('Y', 'N')

Authorization flag for DELETE operations.

Table: PUBLIC_HOLIDAYS

List of dates where DML operations are globally restricted (Added in Phase VII).

Column Name

Data Type

Constraints

Description

HOLIDAY_ID

NUMBER(10)

PK

Identity Column.

HOLIDAY_DATE

DATE

UK, NOT NULL

The specific date of the holiday.

DESCRIPTION

VARCHAR2(100)

NOT NULL

Name of the holiday (e.g., 'Christmas').

2. Transactional Logs (Facts)

Table: ACCESS_LOG

General history of all login attempts (Success and Failure).

Column Name

Data Type

Constraints

Description

LOG_ID

NUMBER(15)

PK

Sequence generated ID.

USERNAME

VARCHAR2(50)

NOT NULL

The user attempting access.

LOGON_TIME

TIMESTAMP

DEFAULT SYSTIMESTAMP

Exact timestamp of the event.

IP_ADDRESS

VARCHAR2(45)



Source IP of the connection.

LOGON_STATUS

VARCHAR2(20)

NOT NULL

Outcome (e.g., 'Success', 'Failed').

Table: SECURITY_ALERTS

High-priority log for anomalies and security violations.

Column Name

Data Type

Constraints

Description

ALERT_ID

NUMBER(15)

PK

Sequence generated ID.

ALERT_TIME

TIMESTAMP

DEFAULT SYSTIMESTAMP

Exact timestamp of the violation.

USERNAME

VARCHAR2(50)

NOT NULL

The user involved in the incident.

IP_ADDRESS

VARCHAR2(45)



Source IP involved.

ALERT_TYPE

VARCHAR2(30)

NOT NULL

Classification (e.g., 'OFF_HOURS', 'UNAUTH_IP').

ALERT_DETAILS

VARCHAR2(4000)



Detailed error message or context dump.

Table: AUDIT_HISTORY

Granular change tracking for sensitive configuration changes (Added in Phase VII).

Column Name

Data Type

Constraints

Description

AUDIT_ID

NUMBER(15)

PK

Identity Column.

TABLE_NAME

VARCHAR2(30)

NOT NULL

The table where data was changed.

OPERATION

VARCHAR2(10)

NOT NULL

Type of change (INS, UPD, DEL).

RECORD_PK

VARCHAR2(100)



Primary Key of the affected row.

OLD_VALUE

VARCHAR2(4000)



Data snapshot before the change.

NEW_VALUE

VARCHAR2(4000)



Data snapshot after the change.

CHANGED_BY

VARCHAR2(50)



The database user who performed the DML.

CHANGE_TIMESTAMP

TIMESTAMP

DEFAULT SYSTIMESTAMP

Time of the change.