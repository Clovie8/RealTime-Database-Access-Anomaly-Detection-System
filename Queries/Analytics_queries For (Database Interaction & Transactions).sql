-- Objective: Validate all components (Functions, Procedures, Package, View).
--------------------------------------------------------------------------------
-- Disable define to prevent "Enter Value" popups
SET DEFINE OFF;
SET SERVEROUTPUT ON;

UPDATE APP_USERS 
SET normal_start_time = '00:00', normal_end_time = '23:59' 
WHERE username = 'FIN_MGR_JDOE';
COMMIT;

DECLARE
    v_status    VARCHAR2(50);
    v_risk      NUMBER;
    v_deleted   NUMBER;
    v_test_user VARCHAR2(50) := 'FIN_MGR_JDOE'; -- Valid User
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST 1: FUNCTIONS ===');
    
    -- Test Risk Score Calculation
    v_risk := fn_get_risk_score(v_test_user);
    DBMS_OUTPUT.PUT_LINE('Risk Score for ' || v_test_user || ': ' || v_risk);
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== TEST 2: PROCEDURES ===');
    
    -- Test 2.1: Successful Login (Edge Case: Valid)
    -- Ensure you use an IP that IS in the ALLOWED_IPS table for this user
    sp_process_login(v_test_user, '192.168.10.5', v_status);
    DBMS_OUTPUT.PUT_LINE('Test 2.1 (Valid): ' || v_status);
    
    -- Test 2.2: Failed Login (Edge Case: Invalid IP)
    BEGIN
        sp_process_login(v_test_user, '99.99.99.99', v_status);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Test 2.2 (Invalid IP) Caught Exception: ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== TEST 3: PACKAGE & CURSORS ===');
    
    -- Test Bulk Archive
    PKG_SEC_MAINTENANCE.sp_archive_logs(365, v_deleted);
    DBMS_OUTPUT.PUT_LINE('Rows Archived (Bulk Delete): ' || v_deleted);
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== TEST 4: WINDOW FUNCTIONS VIEW ===');
    
    -- Loop through the view to prove it works
    FOR rec IN (SELECT username, rolling_failure_count FROM V_SEC_ANALYTICS_FULL WHERE rownum <= 3) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('User: ' || rec.username || ' | Rolling Failures: ' || rec.rolling_failure_count);
    END LOOP;
END;
/