#!/bin/bash
set -euo pipefail

# Author: Ranjan Akarsh

# ETLGuard Main Orchestrator
# Sources all modules and coordinates monitoring, healing, validation, and notification

# Directories
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$ROOT_DIR/config"
LOG_DIR="$ROOT_DIR/logs"
MODULES_DIR="$ROOT_DIR/modules"
REPORTS_DIR="$ROOT_DIR/reports"
STATE_DIR="$ROOT_DIR/state"

# Source utils
source "$MODULES_DIR/utils.sh"

# Source modules
source "$MODULES_DIR/monitor.sh"
source "$MODULES_DIR/parser.sh"
source "$MODULES_DIR/healer.sh"
source "$MODULES_DIR/validator.sh"
source "$MODULES_DIR/notifier.sh"

# Config files
JOBS_CONF="$CONFIG_DIR/jobs.conf"
DB_CONF="$CONFIG_DIR/db.conf"
LOG_FILE="$LOG_DIR/etlguard.log"
STATE_DB="$STATE_DIR/job_state.db"

# Main loop: iterate over jobs
job_lines=()
while IFS= read -r line; do
  # Skip comments and blank lines
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  job_lines+=("$line")
done < "$JOBS_CONF"

for job_line in "${job_lines[@]}"; do
    set +e
    IFS='|' read -r job_id job_name log_path db_validation_query <<< "$job_line"
    [[ -z "$job_id" ]] && continue

    # Initialize variables to avoid unbound errors
    failure_reason=""
    heal_result=""

    # Resolve log_path relative to ROOT_DIR if not absolute
    if [[ "$log_path" != /* ]]; then
        resolved_log_path="$ROOT_DIR/$log_path"
    else
        resolved_log_path="$log_path"
    fi

    log_info "Checking job: $job_name ($job_id)"
    echo "DEBUG: Processing job_id: $job_id" >&2

    # 1. Monitor job status
    monitor_job "$job_id" "$job_name" "$resolved_log_path"
    job_status=$?

    if [[ $job_status -ne 0 ]]; then
        log_warn "Job $job_name failed. Parsing logs."
        failure_reason=$(parse_log "$resolved_log_path")
        log_warn "Failure reason: $failure_reason"

        heal_result=$(heal_job "$job_id" "$job_name" "$failure_reason")
        log_info "Healing result: $heal_result"

        # Mark as FAILURE and notify, then continue to next job
        update_job_state "$job_id" "FAILURE"
        notify_failure "$job_id" "$job_name" "$failure_reason" "$heal_result" ""
        continue
    fi

    # 4. Validate job success
    validation_result=$(validate_job "$job_id" "$job_name" "$db_validation_query")
    if [[ "$validation_result" == "SUCCESS" ]]; then
        log_info "Validation passed for $job_name."
        update_job_state "$job_id" "SUCCESS"
    else
        log_error "Validation failed for $job_name: $validation_result"
        update_job_state "$job_id" "FAILURE"
        # 5. Notify
        notify_failure "$job_id" "$job_name" "$failure_reason" "$heal_result" "$validation_result"
    fi

    set -e
done

# 6. Generate daily summary report
summary_file="$REPORTS_DIR/summary_$(date +%Y%m%d).txt"
generate_summary_report "$summary_file"

log_info "ETLGuard run complete. Summary: $summary_file" 