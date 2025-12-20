-- 1. Simple Trigger: Enforce Time/Holiday Restrictions (BEFORE STATEMENT)
-- 2. Compound Trigger: Comprehensive Auditing (FOR EACH ROW)
--------------------------------------------------------------------------------

-- 1. SIMPLE TRIGGER (The Guard)
-- Blocks the action immediately if the date rules aren't met.
CREATE OR REPLACE TRIGGER trg_restrict_weekend_work
BEFORE INSERT OR UPDATE OR DELETE ON SENSITIVE_TABLE_CONFIG
BEGIN
    -- Call our logic function
    IF fn_is_work_permitted(SYSDATE) = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Security Violation: DML Operations are RESTRICTED on Weekdays and Public Holidays.');
    END IF;
END;
/

-- 2. COMPOUND TRIGGER (The Auditor)
-- Captures Old/New values efficiently.
CREATE OR REPLACE TRIGGER trg_audit_sensitive_config
FOR INSERT OR UPDATE OR DELETE ON SENSITIVE_TABLE_CONFIG
COMPOUND TRIGGER

    -- Variables to hold state
    v_op     VARCHAR2(10);
    v_pk     VARCHAR2(100);
    v_old    VARCHAR2(4000);
    v_new    VARCHAR2(4000);

    -- AFTER EACH ROW: Capture the data changes
    AFTER EACH ROW IS
    BEGIN
        -- Determine Operation Type
        IF INSERTING THEN
            v_op := 'INS';
            v_pk := :NEW.config_id;
            v_old := NULL;
            v_new := 'Table: ' || :NEW.table_name || ' | User: ' || :NEW.username || ' | Ins: ' || :NEW.can_insert;
        ELSIF UPDATING THEN
            v_op := 'UPD';
            v_pk := :OLD.config_id;
            v_old := 'Ins: ' || :OLD.can_insert || ' | Upd: ' || :OLD.can_update;
            v_new := 'Ins: ' || :NEW.can_insert || ' | Upd: ' || :NEW.can_update;
        ELSIF DELETING THEN
            v_op := 'DEL';
            v_pk := :OLD.config_id;
            v_old := 'Table: ' || :OLD.table_name || ' | User: ' || :OLD.username;
            v_new := NULL;
        END IF;

        -- Call the logging procedure
        sp_add_audit_log('SENSITIVE_TABLE_CONFIG', v_op, v_pk, v_old, v_new);
    END AFTER EACH ROW;

END trg_audit_sensitive_config;
/