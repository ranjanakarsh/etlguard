#!/bin/bash
# Author: Ranjan Akarsh
set -euo pipefail

# Timestamp function
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Logging functions
log_info() {
    echo "$(timestamp) [INFO] $*" | tee -a "$LOG_FILE"
}

log_warn() {
    echo "$(timestamp) [WARN] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "$(timestamp) [ERROR] $*" | tee -a "$LOG_FILE" >&2
}

# Update job state in flat file DB (job_id|status|timestamp)
update_job_state() {
    local job_id="$1"
    local status="$2"
    local ts
    ts="$(timestamp)"
    # Remove old entry and blank lines
    grep -v "^$job_id|" "$STATE_DB" | grep -v '^$' > "$STATE_DB.tmp" || true
    mv "$STATE_DB.tmp" "$STATE_DB"
    # Add new entry
    echo "$job_id|$status|$ts" >> "$STATE_DB"
}

# Generate daily summary report
generate_summary_report() {
    local summary_file="$1"
    local date_today
    date_today="$(date '+%Y-%m-%d')"

    echo "ETLGuard Daily Summary - $date_today" > "$summary_file"
    echo "=====================================" >> "$summary_file"
    if [[ ! -f "$STATE_DB" ]]; then
        echo "No job state data found." >> "$summary_file"
        return
    fi
    local success_count failure_count
    success_count=$(grep '|SUCCESS|' "$STATE_DB" | grep -v '^$' | wc -l | xargs)
    failure_count=$(grep '|FAILURE|' "$STATE_DB" | grep -v '^$' | wc -l | xargs)
    echo "Successes: $success_count" >> "$summary_file"
    echo "Failures: $failure_count" >> "$summary_file"
    echo "" >> "$summary_file"
    echo "Failed Jobs:" >> "$summary_file"
    if ! grep '|FAILURE|' "$STATE_DB" | grep -v '^$' >> "$summary_file"; then
        echo "None" >> "$summary_file"
    fi
    echo "" >> "$summary_file"
    echo "Successful Jobs:" >> "$summary_file"
    if ! grep '|SUCCESS|' "$STATE_DB" | grep -v '^$' >> "$summary_file"; then
        echo "None" >> "$summary_file"
    fi
} 