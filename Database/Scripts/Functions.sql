-- Objective: Implement Validation, Lookup, and Calculation logic.
--------------------------------------------------------------------------------

-- 1. VALIDATION FUNCTION: Check if current time is within allowed window
CREATE OR REPLACE FUNCTION fn_is_time_valid(
    p_username IN VARCHAR2
) RETURN NUMBER IS -- Returns 1 (True) or 0 (False)
    v_start VARCHAR2(5);
    v_end   VARCHAR2(5);
    v_now   VARCHAR2(5);
BEGIN
    SELECT normal_start_time, normal_end_time 
    INTO v_start, v_end
    FROM APP_USERS WHERE username = p_username;

    v_now := TO_CHAR(SYSDATE, 'HH24:MI');

    IF v_now BETWEEN v_start AND v_end THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0; -- Fail safe
END fn_is_time_valid;
/

-- 2. LOOKUP FUNCTION: Check IP Whitelist status
CREATE OR REPLACE FUNCTION fn_check_ip_whitelist(
    p_username IN VARCHAR2,
    p_ip_address IN VARCHAR2
) RETURN NUMBER IS
    v_enforce CHAR(1);
    v_count   NUMBER;
    v_uid     NUMBER;
BEGIN
    -- Lookup user configuration
    SELECT user_id, enforce_ip_whitelist INTO v_uid, v_enforce
    FROM APP_USERS WHERE username = p_username;

    -- If whitelist is not enforced, return 1 (Allowed)
    IF v_enforce = 'N' THEN RETURN 1; END IF;

    -- Check specific IP match
    SELECT COUNT(*) INTO v_count 
    FROM ALLOWED_IPS 
    WHERE user_id = v_uid AND ip_address = p_ip_address;

    IF v_count > 0 THEN RETURN 1; ELSE RETURN 0; END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
END fn_check_ip_whitelist;
/

-- 3. CALCULATION FUNCTION: Compute Risk Score (0-100)
CREATE OR REPLACE FUNCTION fn_get_risk_score(
    p_username IN VARCHAR2
) RETURN NUMBER IS
    v_score NUMBER := 0;
    v_failed_logins NUMBER;
BEGIN
    -- Calculate failures in last 24 hours
    SELECT COUNT(*) INTO v_failed_logins
    FROM ACCESS_LOG 
    WHERE username = p_username 
      AND logon_status = 'Failed' 
      AND logon_time > SYSDATE - 1;
      
    -- Logic: 20 points per failure
    v_score := v_failed_logins * 20;
    
    -- Cap at 100
    IF v_score > 100 THEN v_score := 100; END IF;
    
    RETURN v_score;
END fn_get_risk_score;
/