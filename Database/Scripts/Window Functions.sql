-- Objective: Implement complex analytics using all required Window functions.
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW V_SEC_ANALYTICS_FULL AS
SELECT 
    username,
    logon_time,
    ip_address,
    logon_status,

    -- 1. ROW_NUMBER: Unique ID for session within user history
    ROW_NUMBER() OVER (PARTITION BY username ORDER BY logon_time DESC) as session_rank,

    -- 2. RANK: Rank sessions globally by time (allows gaps)
    RANK() OVER (ORDER BY logon_time DESC) as global_time_rank,

    -- 3. DENSE_RANK: Rank IPs by popularity (no gaps)
    DENSE_RANK() OVER (ORDER BY ip_address) as ip_popularity_rank,

    -- 4. LAG: Check Previous Login Time (Brute Force Detection)
    LAG(logon_time, 1) OVER (PARTITION BY username ORDER BY logon_time) as prev_login,

    -- 5. LEAD: Check Next Login Status
    LEAD(logon_status, 1) OVER (PARTITION BY username ORDER BY logon_time) as next_status,

    -- 6. AGGREGATE OVER: Rolling count of failures (Last 5 attempts)
    COUNT(CASE WHEN logon_status = 'Failed' THEN 1 END) 
        OVER (PARTITION BY username ORDER BY logon_time ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) 
    as rolling_failure_count

FROM ACCESS_LOG;
/