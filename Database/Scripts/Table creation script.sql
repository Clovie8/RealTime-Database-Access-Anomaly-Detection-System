--------------------------------------------------------------------------------
-- PHASE V: TABLE IMPLEMENTATION (DDL)
-- User: SEC_ADMIN
-- Project: Real-time Database Access Anomaly Detection
--------------------------------------------------------------------------------

-- 2. CREATE SEQUENCES
CREATE SEQUENCE app_users_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE allowed_ips_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE config_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE log_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE alert_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- 3. CREATE TABLES

-- Table: APP_USERS
CREATE TABLE APP_USERS (
    user_id                     NUMBER(10)      DEFAULT app_users_seq.NEXTVAL PRIMARY KEY,
    username                    VARCHAR2(50)    NOT NULL UNIQUE,
    normal_start_time           VARCHAR2(5)     NOT NULL, -- Format '08:00'
    normal_end_time             VARCHAR2(5)     NOT NULL, -- Format '18:00'
    enforce_ip_whitelist        CHAR(1)         DEFAULT 'N' NOT NULL,
    CONSTRAINT chk_ip_enforce CHECK (enforce_ip_whitelist IN ('Y', 'N'))
) TABLESPACE SEC_DATA;

-- Table: ALLOWED_IPS
CREATE TABLE ALLOWED_IPS (
    ip_id                       NUMBER(10)      DEFAULT allowed_ips_seq.NEXTVAL PRIMARY KEY,
    user_id                     NUMBER(10)      NOT NULL,
    ip_address                  VARCHAR2(45)    NOT NULL,
    description                 VARCHAR2(100),
    CONSTRAINT fk_app_user_ip FOREIGN KEY (user_id) REFERENCES APP_USERS(user_id)
) TABLESPACE SEC_DATA;

-- Table: SENSITIVE_TABLE_CONFIG
CREATE TABLE SENSITIVE_TABLE_CONFIG (
    config_id                   NUMBER(10)      DEFAULT config_seq.NEXTVAL PRIMARY KEY,
    table_name                  VARCHAR2(50)    NOT NULL,
    username                    VARCHAR2(50)    NOT NULL,
    can_insert                  CHAR(1)         DEFAULT 'N' NOT NULL CHECK (can_insert IN ('Y', 'N')),
    can_update                  CHAR(1)         DEFAULT 'N' NOT NULL CHECK (can_update IN ('Y', 'N')),
    can_delete                  CHAR(1)         DEFAULT 'N' NOT NULL CHECK (can_delete IN ('Y', 'N')),
    CONSTRAINT fk_config_username FOREIGN KEY (username) REFERENCES APP_USERS(username)
) TABLESPACE SEC_DATA;

-- Table: ACCESS_LOG
CREATE TABLE ACCESS_LOG (
    log_id                      NUMBER(15)      DEFAULT log_seq.NEXTVAL PRIMARY KEY,
    username                    VARCHAR2(50)    NOT NULL,
    logon_time                  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    ip_address                  VARCHAR2(45),
    logon_status                VARCHAR2(20)    NOT NULL
) TABLESPACE SEC_DATA;

-- Table: SECURITY_ALERTS
CREATE TABLE SECURITY_ALERTS (
    alert_id                    NUMBER(15)      DEFAULT alert_seq.NEXTVAL PRIMARY KEY,
    alert_time                  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    username                    VARCHAR2(50)    NOT NULL,
    ip_address                  VARCHAR2(45),
    alert_type                  VARCHAR2(30)    NOT NULL,
    alert_details               VARCHAR2(4000)
) TABLESPACE SEC_DATA;

-- 4. CREATE INDEXES
CREATE INDEX idx_ip_user_id ON ALLOWED_IPS (user_id) TABLESPACE SEC_IDX;
CREATE INDEX idx_config_username ON SENSITIVE_TABLE_CONFIG (username) TABLESPACE SEC_IDX;
CREATE INDEX idx_log_user_time ON ACCESS_LOG (username, logon_time) TABLESPACE SEC_IDX;
CREATE INDEX idx_alert_time_type ON SECURITY_ALERTS (alert_time, alert_type) TABLESPACE SEC_IDX;

COMMIT;