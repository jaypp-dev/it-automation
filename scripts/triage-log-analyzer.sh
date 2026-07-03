#!/bin/bash
# triage-log-analyzer.sh
# A simple utility script to parse application log files for rapid Tier 1 triage.
# This script simulates extracting error counts to isolate platform environment issues.

LOG_FILE="simulated_app.log"

# Create a dummy log file if one doesn't exist for demonstration
if [ ! -f "$LOG_FILE" ]; then
    echo "[2026-07-03 08:00:12] INFO: User access request granted." > "$LOG_FILE"
    echo "[2026-07-03 08:15:45] ERROR: Connection timeout on database." >> "$LOG_FILE"
    echo "[2026-07-03 08:22:10] WARN: High latency detected on service ingress." >> "$LOG_FILE"
    echo "[2026-07-03 08:45:30] ERROR: Application failed to handle incoming request (HTTP 500)." >> "$LOG_FILE"
fi

echo "=========================================="
echo "   TIER 1 LOG TRIAGE UTILITY"
echo "=========================================="
echo "Analyzing logs in: $LOG_FILE"
echo ""

# Count total errors
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
echo "Total critical errors found: $ERROR_COUNT"
echo "------------------------------------------"

# Display the specific lines containing errors
echo "Detailed Error Lines:"
grep "ERROR" "$LOG_FILE"
echo "=========================================="
