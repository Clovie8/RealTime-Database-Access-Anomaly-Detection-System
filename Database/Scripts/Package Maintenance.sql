-- Objective: Group related maintenance procedures, use Bulk Operations.
--------------------------------------------------------------------------------

-- PACKAGE SPECIFICATION
CREATE OR REPLACE PACKAGE PKG_SEC_MAINTENANCE AS
    
    -- Procedure 4: Bulk Archive (Uses Cursors)
    PROCEDURE sp_archive_logs(
        p_days_retention IN NUMBER,
        p_deleted_count  OUT NUMBER
    );
    
    -- Procedure 5: Daily Stats (Uses Aggregation)
    PROCEDURE sp_generate_daily_stats;

END PKG_SEC_MAINTENANCE;
/

-- PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY PKG_SEC_MAINTENANCE AS

    -- IMPLEMENTATION: Bulk Archive
    PROCEDURE sp_archive_logs(
        p_days_retention IN NUMBER,
        p_deleted_count  OUT NUMBER
    ) IS
        -- Explicit Cursor Definition
        CURSOR c_old_logs IS
            SELECT log_id FROM ACCESS_LOG 
            WHERE logon_time < SYSDATE - p_days_retention;
            
        TYPE t_log_ids IS TABLE OF ACCESS_LOG.log_id%TYPE;
        v_ids t_log_ids;
    BEGIN
        p_deleted_count := 0;
        
        -- Cursor Lifecycle: OPEN
        OPEN c_old_logs;
        LOOP
            -- Bulk Operation: FETCH
            FETCH c_old_logs BULK COLLECT INTO v_ids LIMIT 500;
            EXIT WHEN v_ids.COUNT = 0;
            
            -- Bulk Operation: FORALL (Optimization)
            FORALL i IN 1..v_ids.COUNT
                DELETE FROM ACCESS_LOG WHERE log_id = v_ids(i);
                
            p_deleted_count := p_deleted_count + SQL%ROWCOUNT;
            COMMIT;
        END LOOP;
        
        -- Cursor Lifecycle: CLOSE
        CLOSE c_old_logs;
    END sp_archive_logs;

    -- IMPLEMENTATION: Daily Stats
    PROCEDURE sp_generate_daily_stats IS
    BEGIN
        -- Simple maintenance task to check db health
        NULL; -- Placeholder for logic extending beyond requirements
    END sp_generate_daily_stats;

END PKG_SEC_MAINTENANCE;
/