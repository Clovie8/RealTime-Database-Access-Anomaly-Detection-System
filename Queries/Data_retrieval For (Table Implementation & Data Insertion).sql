--------------------------------------------------------------------------------
-- PHASE V: VERIFICATION & TESTING
--------------------------------------------------------------------------------

-- TEST 1: Data Completeness Check
-- Verify we met the row count requirements
SELECT 'APP_USERS' as TABLE_NAME, COUNT(*) as ROW_COUNT FROM APP_USERS
UNION ALL
SELECT 'ACCESS_LOG', COUNT(*) FROM ACCESS_LOG
UNION ALL
SELECT 'SECURITY_ALERTS', COUNT(*) FROM SECURITY_ALERTS;

-- TEST 2: Basic Retrieval with Filtering (Where Clause)
-- Find all failed logins in the system
SELECT * FROM ACCESS_LOG 
WHERE logon_status = 'Failed'
FETCH FIRST 10 ROWS ONLY;

-- TEST 3: JOIN Query (Multi-table)
-- List users, their departments (roles), and their allowed IP descriptions
SELECT 
    u.username,
    u.normal_start_time,
    u.enforce_ip_whitelist,
    i.ip_address as WHITELISTED_IP,
    i.description
FROM APP_USERS u
LEFT JOIN ALLOWED_IPS i ON u.user_id = i.user_id;

-- TEST 4: Aggregation (GROUP BY)
-- Count how many alerts have been triggered per Alert Type
SELECT 
    alert_type,
    COUNT(*) as incident_count,
    MIN(alert_time) as first_occurrence,
    MAX(alert_time) as latest_occurrence
FROM SECURITY_ALERTS
GROUP BY alert_type
ORDER BY incident_count DESC;

-- TEST 5: Complex Subquery
-- Find users who have generated more Logs than the average user
SELECT username, COUNT(*) as log_count
FROM ACCESS_LOG
GROUP BY username
HAVING COUNT(*) > (
    SELECT AVG(count_per_user)
    FROM (
        SELECT COUNT(*) as count_per_user 
        FROM ACCESS_LOG 
        GROUP BY username
    )
)
ORDER BY log_count DESC;
