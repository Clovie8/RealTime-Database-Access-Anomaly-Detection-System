Data Dictionary

Project: Real-time Database Access Anomaly Detection
Schema Owner: SEC_ADMIN

1. Core Configuration Tables (Dimensions)

Table

Column

Type

Constraints

Purpose

APP_USERS

USER_ID

NUMBER(10)

PK

Surrogate Primary Key (Sequence generated).

APP_USERS

USERNAME

VARCHAR2(50)

UK, NOT NULL

Oracle DB Username. Links to logs/configs.

APP_USERS

NORMAL_START_TIME

VARCHAR2(5)

NOT NULL

Start of allowed business window (Format: 'HH24:MI').

APP_USERS

NORMAL_END_TIME

VARCHAR2(5)

NOT NULL

End of allowed business window (Format: 'HH24:MI').

APP_USERS

ENFORCE_IP_WHITELIST

CHAR(1)

CHECK ('Y', 'N')

Flag to enable/disable IP address validation.

ALLOWED_IPS

IP_ID

NUMBER(10)

PK

Surrogate Primary Key for whitelist entries.

ALLOWED_IPS

USER_ID

NUMBER(10)

FK

Links to APP_USERS.USER_ID.

ALLOWED_IPS

IP_ADDRESS

VARCHAR2(45)

NOT NULL

IPv4 or IPv6 address allowed for connection.

ALLOWED_IPS

DESCRIPTION

VARCHAR2(100)

None

Context notes (e.g., 'VPN', 'Office HQ').

SENSITIVE_TABLE_CONFIG

CONFIG_ID

NUMBER(10)

PK

Surrogate Primary Key.

SENSITIVE_TABLE_CONFIG

TABLE_NAME

VARCHAR2(50)

NOT NULL

The target table being protected.

SENSITIVE_TABLE_CONFIG

USERNAME

VARCHAR2(50)

FK

Links to APP_USERS.USERNAME.

SENSITIVE_TABLE_CONFIG

CAN_INSERT

CHAR(1)

CHECK ('Y', 'N')

Authorization flag for INSERT operations.

SENSITIVE_TABLE_CONFIG

CAN_UPDATE

CHAR(1)

CHECK ('Y', 'N')

Authorization flag for UPDATE operations.

SENSITIVE_TABLE_CONFIG

CAN_DELETE

CHAR(1)

CHECK ('Y', 'N')

Authorization flag for DELETE operations.

PUBLIC_HOLIDAYS

HOLIDAY_ID

NUMBER(10)

PK

Identity Column.

PUBLIC_HOLIDAYS

HOLIDAY_DATE

DATE

UK, NOT NULL

The specific date of the holiday where DML is restricted.

PUBLIC_HOLIDAYS

DESCRIPTION

VARCHAR2(100)

NOT NULL

Name of the holiday (e.g., 'Christmas').

2. Transactional Log Tables (Facts)

Table

Column

Type

Constraints

Purpose

ACCESS_LOG

LOG_ID

NUMBER(15)

PK

Sequence generated ID for the log entry.

ACCESS_LOG

USERNAME

VARCHAR2(50)

NOT NULL

The user attempting access.

ACCESS_LOG

LOGON_TIME

TIMESTAMP

DEFAULT SYSTIMESTAMP

Exact timestamp of the login event.

ACCESS_LOG

IP_ADDRESS

VARCHAR2(45)

None

Source IP of the connection.

ACCESS_LOG

LOGON_STATUS

VARCHAR2(20)

NOT NULL

Outcome (e.g., 'Success', 'Failed').

SECURITY_ALERTS

ALERT_ID

NUMBER(15)

PK

Sequence generated ID for high-priority alerts.

SECURITY_ALERTS

ALERT_TIME

TIMESTAMP

DEFAULT SYSTIMESTAMP

Exact timestamp of the violation.

SECURITY_ALERTS

USERNAME

VARCHAR2(50)

NOT NULL

The user involved in the incident.

SECURITY_ALERTS

IP_ADDRESS

VARCHAR2(45)

None

Source IP involved in the anomaly.

SECURITY_ALERTS

ALERT_TYPE

VARCHAR2(30)

NOT NULL

Classification (e.g., 'OFF_HOURS', 'UNAUTH_IP').

SECURITY_ALERTS

ALERT_DETAILS

VARCHAR2(4000)

None

Detailed error message or context dump.

AUDIT_HISTORY

AUDIT_ID

NUMBER(15)

PK

Identity Column for audit trails.

AUDIT_HISTORY

TABLE_NAME

VARCHAR2(30)

NOT NULL

The table where data was changed.

AUDIT_HISTORY

OPERATION

VARCHAR2(10)

NOT NULL

Type of change (INS, UPD, DEL).

AUDIT_HISTORY

RECORD_PK

VARCHAR2(100)

None

Primary Key of the affected row.

AUDIT_HISTORY

OLD_VALUE

VARCHAR2(4000)

None

Data snapshot before the change.

AUDIT_HISTORY

NEW_VALUE

VARCHAR2(4000)

None

Data snapshot after the change.

AUDIT_HISTORY

CHANGED_BY

VARCHAR2(50)

None

The database user who performed the DML.

AUDIT_HISTORY

CHANGE_TIMESTAMP

TIMESTAMP

DEFAULT SYSTIMESTAMP

Time of the change.