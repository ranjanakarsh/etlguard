#!/bin/bash
set -euo pipefail

# Author: Ranjan Akarsh

notify_failure() {
    local job_id="$1"
    local job_name="$2"
    local failure_reason="$3"
    local heal_result="$4"
    local validation_result="$5"

    # Simulate sending email and Slack alert
    log_warn "ALERT: Job $job_name ($job_id) failed. Reason: $failure_reason | Heal: $heal_result | Validation: $validation_result"
    # In production, use mailx/sendmail and curl for Slack webhook
    # Example:
    # echo "Job $job_name failed: $failure_reason" | mailx -s "ETLGuard Alert: $job_name" you@example.com
    # curl -X POST -H 'Content-type: application/json' --data '{"text":"Job $job_name failed: $failure_reason"}' $SLACK_WEBHOOK_URL
} 