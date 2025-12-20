import oracledb
from flask import Flask, jsonify
from flask_cors import CORS
import sys

app = Flask(__name__)
CORS(app)

# --- CONFIGURATION FOR LOCAL ORACLE 21c ---

DB_USER = "SEC_ADMIN"
DB_PASS = "clovis"

# OPTION 1: Try this first (Standard for Oracle XE)
DB_DSN  = "localhost:1521/thu_27122_clovis_dbaccessad_db"

# OPTION 2: If Option 1 fails, try this (Pluggable Database)
# DB_DSN = "localhost:1521/XEPDB1" 

def get_db_connection():
    try:
        # Connect strictly in Thin mode for local DB (No Wallet needed)
        connection = oracledb.connect(
            user=DB_USER, 
            password=DB_PASS, 
            dsn=DB_DSN
        )
        return connection
    except oracledb.Error as e:
        print(f"❌ Database Connection Error: {e}")
        return None

@app.route('/api/stats', methods=['GET'])
def get_dashboard_stats():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Could not connect to Oracle Database. Check console."}), 500

    cursor = conn.cursor()
    data = {}

    try:
        # 1. KPI: Total Connections
        cursor.execute("SELECT COUNT(*) FROM ACCESS_LOG")
        data['total_connections'] = cursor.fetchone()[0]

        # 2. KPI: Threats Blocked
        cursor.execute("SELECT COUNT(*) FROM SECURITY_ALERTS")
        data['threats_blocked'] = cursor.fetchone()[0]

        # 3. KPI: Suspicious IPs
        cursor.execute("SELECT COUNT(DISTINCT IP_ADDRESS) FROM SECURITY_ALERTS")
        data['suspicious_ips'] = cursor.fetchone()[0]
        
        # 4. KPI: System Health
        total_activity = data['total_connections'] + data['threats_blocked']
        if total_activity > 0:
            health = 100 - (data['threats_blocked'] / total_activity * 100)
        else:
            health = 100
        data['system_health'] = round(health, 1)

        # 5. Recent Logs
        query_logs = """
            SELECT * FROM (
                SELECT TO_CHAR(LOGON_TIME, 'HH24:MI:SS') as t, USERNAME, IP_ADDRESS, 'LOGIN', LOGON_STATUS 
                FROM ACCESS_LOG
                UNION ALL
                SELECT TO_CHAR(ALERT_TIME, 'HH24:MI:SS') as t, USERNAME, IP_ADDRESS, ALERT_TYPE, 'BLOCKED' 
                FROM SECURITY_ALERTS
            ) ORDER BY t DESC FETCH FIRST 7 ROWS ONLY
        """
        cursor.execute(query_logs)
        
        logs = []
        for row in cursor:
            logs.append({
                "time": row[0],
                "user": row[1],
                "ip": row[2],
                "op": row[3],
                "status": row[4]
            })

        return jsonify({"kpi": data, "logs": logs})

    except oracledb.Error as e:
        print(f"❌ Query Error: {e}")
        return jsonify({"error": str(e)}), 500
    finally:
        if cursor: cursor.close()
        if conn: conn.close()

if __name__ == '__main__':
    print(f"🚀 Starting SecureDB API Bridge on http://localhost:5000")
    print(f"🔌 Connecting to Local Oracle 21c as {DB_USER}...")
    app.run(debug=True, port=5000)