--------------------------------------------------------------------------------
-- PHASE V: DATA INSERTION (DML)
-- Objective: Generate 500+ realistic rows including edge cases.
--------------------------------------------------------------------------------

SET SERVEROUTPUT ON;

BEGIN
    -- 1. INSERT CORE USERS (Demographic Mix)
    -- Admin (No IP restrictions)
    INSERT INTO APP_USERS (username, normal_start_time, normal_end_time, enforce_ip_whitelist)
    VALUES ('SEC_ADMIN', '00:00', '23:59', 'N');

    -- Finance Manager (Standard Hours, Strict IP)
    INSERT INTO APP_USERS (username, normal_start_time, normal_end_time, enforce_ip_whitelist)
    VALUES ('FIN_MGR_JDOE', '08:00', '18:00', 'Y');

    -- HR Analyst (Shift Work, Loose IP)
    INSERT INTO APP_USERS (username, normal_start_time, normal_end_time, enforce_ip_whitelist)
    VALUES ('HR_ANALYST_LSMITH', '07:00', '16:00', 'N');

    -- IT Developer (Late hours allowed)
    INSERT INTO APP_USERS (username, normal_start_time, normal_end_time, enforce_ip_whitelist)
    VALUES ('DEV_KLEE', '10:00', '22:00', 'Y');
    
    -- "Compromised" User (Standard profile)
    INSERT INTO APP_USERS (username, normal_start_time, normal_end_time, enforce_ip_whitelist)
    VALUES ('SALES_REP_MNO', '09:00', '17:00', 'N');

    -- 2. INSERT WHITELISTED IPs
    INSERT INTO ALLOWED_IPS (user_id, ip_address, description) 
    SELECT user_id, '192.168.10.5', 'HQ Finance Desktop' FROM APP_USERS WHERE username = 'FIN_MGR_JDOE';

    INSERT INTO ALLOWED_IPS (user_id, ip_address, description) 
    SELECT user_id, '10.0.0.99', 'Remote VPN' FROM APP_USERS WHERE username = 'DEV_KLEE';

    -- 3. INSERT SENSITIVE TABLE CONFIG
    INSERT INTO SENSITIVE_TABLE_CONFIG (table_name, username, can_insert, can_update, can_delete)
    VALUES ('HR_SALARIES', 'FIN_MGR_JDOE', 'N', 'Y', 'N');
    
    INSERT INTO SENSITIVE_TABLE_CONFIG (table_name, username, can_insert, can_update, can_delete)
    VALUES ('EMP_RECORDS', 'HR_ANALYST_LSMITH', 'Y', 'Y', 'N');

    -- 4. GENERATE MASSIVE LOG DATA (500+ ROWS)
    -- We loop to simulate traffic over the last 30 days
    FOR i IN 1..600 LOOP
        DECLARE
            v_user      VARCHAR2(50);
            v_ip        VARCHAR2(45);
            v_status    VARCHAR2(20);
            v_time      TIMESTAMP;
            v_rand      NUMBER;
        BEGIN
            -- Pick a random user from our list
            SELECT username INTO v_user FROM (SELECT username FROM APP_USERS ORDER BY dbms_random.value) WHERE rownum = 1;
            
            -- Generate Random Time (Last 30 days)
            v_time := SYSTIMESTAMP - NUMTODSINTERVAL(dbms_random.value(0, 30), 'DAY');
            
            -- Generate IP (80% chance of 'Internal', 20% 'External/Unknown')
            IF dbms_random.value < 0.8 THEN
                v_ip := '192.168.1.' || TRUNC(dbms_random.value(1, 255));
                v_status := 'Success';
            ELSE
                v_ip := '203.0.113.' || TRUNC(dbms_random.value(1, 255));
                -- If external, 50% chance of failure
                IF dbms_random.value < 0.5 THEN
                    v_status := 'Failed';
                ELSE
                    v_status := 'Success';
                END IF;
            END IF;

            -- Insert the Log
            INSERT INTO ACCESS_LOG (username, logon_time, ip_address, logon_status)
            VALUES (v_user, v_time, v_ip, v_status);
            
            -- 5. SIMULATE ANOMALIES (Generate Alerts)
            -- Every 50th iteration, inject a "Security Alert"
            IF MOD(i, 50) = 0 THEN
                INSERT INTO SECURITY_ALERTS (alert_time, username, ip_address, alert_type, alert_details)
                VALUES (v_time, v_user, v_ip, 'OFF_HOURS_LOGON', 'User logged in at ' || TO_CHAR(v_time, 'HH24:MI') || ' outside allowed range.');
            END IF;
            
             -- Every 75th iteration, inject a "Brute Force" attempt
            IF MOD(i, 75) = 0 THEN
                INSERT INTO SECURITY_ALERTS (alert_time, username, ip_address, alert_type, alert_details)
                VALUES (v_time, 'UNKNOWN_USER', '1.1.1.1', 'BRUTE_FORCE', '5 Failed attempts in 1 minute.');
            END IF;

        END;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Data Generation Complete: 5 Users, Configs, IPs, and 600+ Logs/Alerts created.');
END;
/