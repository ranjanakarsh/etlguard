#!/bin/bash
set -euo pipefail

# Author: Ranjan Akarsh

parse_log() {
    local log_path="$1"
    local error_pattern

    if [[ ! -f "$log_path" ]]; then
        echo "Log file not found"
        return 1
    fi

    # Known error patterns
    if grep -qE 'ORA-[0-9]{4,}' "$log_path"; then
        error_pattern=$(grep -m1 -E 'ORA-[0-9]{4,}' "$log_path")
        echo "$error_pattern"
        return 0
    elif grep -q 'file not found' "$log_path"; then
        error_pattern=$(grep -m1 'file not found' "$log_path")
        echo "$error_pattern"
        return 0
    elif grep -q -i 'timeout' "$log_path"; then
        error_pattern=$(grep -m1 -i 'timeout' "$log_path")
        echo "$error_pattern"
        return 0
    fi

    echo "Unknown error"
    return 0
} 