-- Implements: Date Checking Function & Audit Logging Procedure
--------------------------------------------------------------------------------

-- 1. RESTRICTION CHECK FUNCTION
-- Logic: Return 1 (Allowed) ONLY if Weekend AND Not Holiday. Otherwise 0 (Blocked).
CREATE OR REPLACE FUNCTION fn_is_work_permitted(
    p_check_date IN DATE DEFAULT SYSDATE
) RETURN NUMBER IS
    v_day_str   VARCHAR2(10);
    v_hol_count NUMBER;
BEGIN
    -- A. Check Day of Week (DY format returns MON, TUE, etc.)
    -- NLS_DATE_LANGUAGE ensures consistency regardless of server region
    v_day_str := TO_CHAR(p_check_date, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');

    -- Rule: Weekdays (MON-FRI) are BLOCKED.
    IF v_day_str NOT IN ('SAT', 'SUN') THEN
        RETURN 0; -- Blocked (Weekday)
    END IF;

    -- B. Check Public Holidays
    SELECT COUNT(*) INTO v_hol_count
    FROM PUBLIC_HOLIDAYS
    WHERE TRUNC(holiday_date) = TRUNC(p_check_date);

    IF v_hol_count > 0 THEN
        RETURN 0; -- Blocked (Holiday)
    END IF;

    -- If we passed both checks, access is allowed.
    RETURN 1; 
END fn_is_work_permitted;
/

-- 2. AUDIT LOGGING PROCEDURE
-- Helper to insert into audit table cleanly
CREATE OR REPLACE PROCEDURE sp_add_audit_log(
    p_table     IN VARCHAR2,
    p_op        IN VARCHAR2,
    p_pk        IN VARCHAR2,
    p_old       IN VARCHAR2,
    p_new       IN VARCHAR2
) IS
BEGIN
    INSERT INTO AUDIT_HISTORY (
        table_name, operation, record_pk, old_value, new_value, changed_by
    ) VALUES (
        p_table, p_op, p_pk, p_old, p_new, USER
    );
END sp_add_audit_log;
/