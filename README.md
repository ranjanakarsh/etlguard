![Shell](https://img.shields.io/badge/Shell-Bash-1f425f)
![CI/CD Ready](https://img.shields.io/badge/CI%2FCD-Ready-brightgreen)
![ETL Monitoring](https://img.shields.io/badge/ETL-Monitoring-blue)

# ETLGuard

**Author: Ranjan Akarsh**

---

## Project Overview
ETLGuard is a modular, fault-tolerant ETL monitoring and self-healing system written in Bash. It is designed to monitor ETL jobs (run via cron, Control-M, or other schedulers), parse logs for known failure patterns, attempt automated recovery, validate job success using Oracle PL/SQL, and send structured alerts. ETLGuard is CI/CD-friendly and easily extensible for enterprise or demo use.

---

## Features
- **Job Monitoring:** Watches ETL jobs and their logs for failures.
- **Log Parsing:** Detects Oracle errors (ORA-xxxx), file not found, timeouts, and more using grep/awk/sed.
- **Self-Healing:** Automatically retries jobs, clears stale locks, or re-establishes DB connections based on error patterns.
- **Oracle Validation:** Runs post-load PL/SQL queries via sqlplus/Oracle Instant Client to confirm data integrity.
- **Alerting:** Sends structured incident reports via email (mailx/sendmail) or Slack (webhook/curl).
- **Daily Reporting:** Generates daily summary reports of job outcomes and recovery actions.
- **State Tracking:** Uses a flat file to track job states for reporting and recovery.
- **Modular Design:** All logic is split into reusable modules, with a single orchestrator entrypoint.
- **Simulation Ready:** Includes test data and mock jobs for demonstration without enterprise infra.

---

## How It Works

### Log Parsing Logic
- Each job's log is scanned for known failure patterns:
  - **Oracle errors:** e.g., `ORA-00054`, `ORA-00942`
  - **File errors:** e.g., `file not found`
  - **Timeouts:** e.g., `timeout waiting for DB connection`
- Patterns are easily extended in `modules/parser.sh`.

### Healing Strategies
- **Lock errors (ORA-00054):** Simulates clearing DB locks.
- **Other Oracle errors:** Simulates reconnecting to the database.
- **File not found/timeouts:** Simulates retrying the job.
- Healing logic is modular and extensible in `modules/healer.sh`.

### Oracle Validation
- After a job runs, a post-load validation query is executed (simulated or real via `sqlplus`).
- If the query passes, the job is marked as SUCCESS; otherwise, FAILURE.
- Validation logic is in `modules/validator.sh`.

---

## How to Run with Sample Data

1. **Generate Sample Logs:**
   ```bash
   cd etlguard/test_data
   ./mock_jobs.sh
   cd ..
   ```
2. **Run ETLGuard:**
   ```bash
   ./etlguard.sh
   ```
3. **Check Results:**
   - Logs: `etlguard/logs/etlguard.log`
   - Daily summary: `etlguard/reports/summary_YYYYMMDD.txt`

---

## How to Integrate into Real Workflows

### Cron/Control-M
- Schedule `etlguard.sh` to run after/between ETL jobs.
- Use the exit code and logs for job chaining or escalation.

### Slack/Email Alerts
- Configure Slack webhook URL or email recipients in `modules/notifier.sh`.
- Uncomment and edit the relevant lines for `mailx` or `curl` in the notifier module.
- Alerts include job name, time, error, and attempted fix.

### Oracle Integration
- Edit `config/db.conf` with real Oracle credentials.
- Update `modules/validator.sh` to run real SQL queries using `sqlplus`.

### CI/CD
- Add as a step in Jenkins, GitHub Actions, or other CI/CD tools.
- All output is plain text and easily parsed for dashboards or further automation.

---

## Folder Structure
```
etlguard/
├── etlguard.sh                 # Main orchestrator script
├── config/
│   ├── jobs.conf               # List of monitored jobs with metadata
│   └── db.conf                 # Oracle DB connection info
├── logs/
│   └── etlguard.log            # Central log file
├── modules/
│   ├── monitor.sh              # Monitors job execution status
│   ├── parser.sh               # Parses job logs for failure patterns
│   ├── healer.sh               # Attempts automatic recovery actions
│   ├── validator.sh            # Runs PL/SQL queries for post-load checks
│   ├── notifier.sh             # Sends email/Slack alerts
│   └── utils.sh                # Shared utility functions
├── reports/
│   └── summary_YYYYMMDD.txt    # Daily summary reports
├── state/
│   └── job_state.db            # Flat file for tracking job states
└── test_data/
    ├── sample_log_1.txt        # Simulated logs for testing
    ├── sample_log_2.txt        # Simulated logs for testing
    ├── sample_log_3.txt        # Simulated logs for testing
    ├── sample_log_4.txt        # Simulated logs for testing
    ├── sample_log_5.txt        # Simulated logs for testing
    └── mock_jobs.sh            # Test job runner for dev use
```

---

**ETLGuard** — by Ranjan Akarsh — is modular, extensible, and ready for real or simulated ETL environments. 
