#!/bin/bash
set -euo pipefail

# Simulate job 1 (success)
echo "$(date '+%Y-%m-%d %H:%M:%S') Starting job" > sample_log_1.txt
echo "$(date '+%Y-%m-%d %H:%M:%S') Processing data" >> sample_log_1.txt
echo "$(date '+%Y-%m-%d %H:%M:%S') JOB SUCCESS" >> sample_log_1.txt

# Simulate job 2 (failure)
echo "$(date '+%Y-%m-%d %H:%M:%S') Starting job" > sample_log_2.txt
echo "$(date '+%Y-%m-%d %H:%M:%S') Processing data" >> sample_log_2.txt
echo "$(date '+%Y-%m-%d %H:%M:%S') ORA-00054: resource busy and acquire with NOWAIT specified" >> sample_log_2.txt

# Complicated recoverable job
cat > sample_log_3.txt <<EOF
2025-05-15 12:00:00 Starting job
2025-05-15 12:00:05 ORA-00054: resource busy and acquire with NOWAIT specified
2025-05-15 12:00:10 file not found: /data/input.csv
2025-05-15 12:00:15 timeout waiting for DB connection
2025-05-15 12:00:20 JOB SUCCESS
EOF

# Unrecoverable error job
cat > sample_log_4.txt <<EOF
2025-05-15 13:00:00 Starting job
2025-05-15 13:00:05 ORA-00942: table or view does not exist
EOF

# Succeeds but fails validation
cat > sample_log_5.txt <<EOF
2025-05-15 14:00:00 Starting job
2025-05-15 14:00:10 JOB SUCCESS
EOF 