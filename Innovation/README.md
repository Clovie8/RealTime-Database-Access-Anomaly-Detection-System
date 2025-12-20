# SecureDB Real-Time Dashboard

This is a modern web-based dashboard designed to visualize real-time security data from the SecureDB Oracle Database. It acts as a Security Operations Center (SOC) interface for monitoring login attempts and threat blocks.

##  Architecture Overview

The application follows a simple client-server model:

### Frontend (index.html):
* Built with **Tailwind CSS** for a professional "Dark Mode" UI.
* Uses **JavaScript (Fetch API)** to poll the backend every 2 seconds.
* Displays **Key Performance Indicators (KPIs)** and a live log table.
* **Behavior:** If the backend is offline, it shows a red "CONNECTION FAILED" status.

### Backend (api_server.py):
* Built with **Python (Flask)**.
* Acts as a bridge between the browser and the Oracle Database.
* **Driver:** Uses `python-oracledb` in "Thin Mode" (no complex installation required).
* **Endpoint:** Exposes `GET /api/stats` which runs SQL queries on `ACCESS_LOG` and `SECURITY_ALERTS` tables and returns JSON data.

---

##  Setup & Usage

### Prerequisites
* Python 3.x installed.
* Oracle Database (21c/XE) running with the `SEC_ADMIN` schema set up.

### Step 1: Configuration
Open `api_server.py` and ensure the database credentials match your setup:

```python
DB_USER = "SEC_ADMIN"
DB_PASS = "clovis"
DB_DSN  = "localhost:1521/thu_27122_clovis_dbaccessad_db"
```

### Step 2: Install Dependencies

Run this command in your terminal to install the required Python libraries:
```Bash
pip install flask flask-cors oracledb
```
### Step 3: Start the Backend

Run the server in your terminal:
```Bash
python api_server.py
```
You should see: 🚀 Starting SecureDB API Bridge on http://localhost:5000
