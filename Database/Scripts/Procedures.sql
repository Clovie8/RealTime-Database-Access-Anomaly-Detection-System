-- Objective: Implement DML, Transaction Logic, and Exception Handling.
--------------------------------------------------------------------------------

-- 1. PROCEDURE: Autonomous Logging (INSERT DML)
-- Purpose: Logs alerts independently of the main transaction (Recovery Mechanism)
CREATE OR REPLACE PROCEDURE sp_log_security_alert(
    p_username      IN VARCHAR2,
    p_ip_address    IN VARCHAR2,
    p_alert_type    IN VARCHAR2,
    p_details       IN VARCHAR2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION; 
BEGIN
    INSERT INTO SECURITY_ALERTS (
        alert_id, alert_time, username, ip_address, alert_type, alert_details
    ) VALUES (
        alert_seq.NEXTVAL, SYSTIMESTAMP, p_username, p_ip_address, p_alert_type, p_details
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN ROLLBACK; -- Recovery mechanism
END sp_log_security_alert;
/

-- 2. PROCEDURE: Main Login Processor (INSERT DML, IN/OUT Params)
CREATE OR REPLACE PROCEDURE sp_process_login(
    p_username      IN VARCHAR2,
    p_ip_address    IN VARCHAR2,
    p_status        OUT VARCHAR2 -- OUT parameter for return status
) IS
    -- Custom Exceptions
    e_bad_time EXCEPTION;
    e_bad_ip   EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_bad_time, -20002);
    PRAGMA EXCEPTION_INIT(e_bad_ip, -20001);
BEGIN
    -- Call Function 1: Validate Time
    IF fn_is_time_valid(p_username) = 0 THEN
        RAISE e_bad_time;
    END IF;

    -- Call Function 2: Validate IP
    IF fn_check_ip_whitelist(p_username, p_ip_address) = 0 THEN
        RAISE e_bad_ip;
    END IF;

    -- Success Logic
    p_status := 'AUTHORIZED';
    
    -- DML: Insert success log
    INSERT INTO ACCESS_LOG (username, ip_address, logon_status) 
    VALUES (p_username, p_ip_address, 'Success');

EXCEPTION
    -- Exception Handling & Error Logging
    WHEN e_bad_time THEN
        p_status := 'BLOCKED_TIME';
        sp_log_security_alert(p_username, p_ip_address, 'OFF_HOURS', 'Login outside allowed window');
        RAISE_APPLICATION_ERROR(-20002, 'Security Violation: Outside Business Hours');

    WHEN e_bad_ip THEN
        p_status := 'BLOCKED_IP';
        sp_log_security_alert(p_username, p_ip_address, 'UNAUTH_IP', 'IP not in whitelist');
        RAISE_APPLICATION_ERROR(-20001, 'Security Violation: Unauthorized IP');
        
    WHEN OTHERS THEN
        p_status := 'SYS_ERROR';
        sp_log_security_alert(p_username, p_ip_address, 'SYSTEM_ERR', SQLERRM);
END sp_process_login;
/

-- 3. PROCEDURE: Reset User Risk (UPDATE DML)
-- Purpose: Manual administrative reset of a user's logs
CREATE OR REPLACE PROCEDURE sp_reset_user_risk(
    p_username IN VARCHAR2
) IS
BEGIN
    -- DML: Update operation
    UPDATE SENSITIVE_TABLE_CONFIG
    SET can_insert = 'N', can_update = 'N', can_delete = 'N'
    WHERE username = p_username;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('User not found.');
END sp_reset_user_risk;
/