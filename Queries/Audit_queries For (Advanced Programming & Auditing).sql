-- Scenario: Testing Weekday Blocks vs Weekend Access
--------------------------------------------------------------------------------
SET SERVEROUTPUT ON;

-- 1. SETUP TEST DATA (Holiday Check)
-- Add "Today" as a holiday to test the holiday blocker specifically
BEGIN
    INSERT INTO PUBLIC_HOLIDAYS (holiday_date, description) VALUES (TRUNC(SYSDATE), 'Test Holiday Today');
    COMMIT;
EXCEPTION WHEN DUP_VAL_ON_INDEX THEN NULL;
END;
/

-- TEST 1: EXPECTED FAILURE
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST 1: EXPECTED FAILURE (Holiday/Weekday Block) ===');
    
    -- Attempt to update a config. 
    -- Since today is Friday AND we added a Holiday, this MUST fail.
    UPDATE SENSITIVE_TABLE_CONFIG 
    SET can_update = 'Y' 
    WHERE config_id = 1;
    
    DBMS_OUTPUT.PUT_LINE('ERROR: The update succeeded but should have been blocked!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Action Blocked correctly.');
        DBMS_OUTPUT.PUT_LINE('Message: ' || SQLERRM);
END;
/

-- 2. CLEANUP HOLIDAY
DELETE FROM PUBLIC_HOLIDAYS WHERE description = 'Test Holiday Today';
COMMIT;

-- TEST 2: SIMULATING WEEKEND
-- Let's test the AUDIT TRIGGER by disabling the Restriction Trigger temporarily
ALTER TRIGGER trg_restrict_weekend_work DISABLE;

BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== TEST 2: SIMULATING WEEKEND (Success Check) ===');

    -- Perform an update (Simulating Allowed Access)
    UPDATE SENSITIVE_TABLE_CONFIG 
    SET can_delete = 'Y' 
    WHERE config_id = (SELECT MIN(config_id) FROM SENSITIVE_TABLE_CONFIG);
    
    DBMS_OUTPUT.PUT_LINE('Update Performed (Restriction Disabled). Checking Audit Log...');
    COMMIT;
END;
/

-- Re-enable the guard
ALTER TRIGGER trg_restrict_weekend_work ENABLE;

-- 3. VERIFY AUDIT LOGS
-- Wrapped in BEGIN/END block to fix "Unknown Command" error
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== AUDIT LOG CONTENTS ===');
    
    FOR rec IN (SELECT operation, old_value, new_value, changed_by, change_timestamp 
                FROM AUDIT_HISTORY 
                ORDER BY audit_id DESC FETCH FIRST 3 ROWS ONLY) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('User: ' || rec.changed_by || ' | Op: ' || rec.operation);
        DBMS_OUTPUT.PUT_LINE('Old: ' || rec.old_value);
        DBMS_OUTPUT.PUT_LINE('New: ' || rec.new_value);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    END LOOP;
END;
/