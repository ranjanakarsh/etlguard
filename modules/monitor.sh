#!/bin/bash
set -euo pipefail

# Author: Ranjan Akarsh

monitor_job() {
    local job_id="$1"
    local job_name="$2"
    local log_path="$3"

    if [[ ! -f "$log_path" ]]; then
        log_warn "Log file $log_path not found for $job_name."
        return 1
    fi
    if grep -q 'JOB SUCCESS' "$log_path"; then
        log_info "Job $job_name succeeded."
        return 0
    else
        log_warn "Job $job_name did not succeed."
        return 1
    fi
} 