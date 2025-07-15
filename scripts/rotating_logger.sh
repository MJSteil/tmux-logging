#!/usr/bin/env bash

set -euo pipefail

logfile="$1"

source "$2/variables.sh"
source "$2/shared.sh"
max_size=${logging_max_size}
check_interval=${logging_max_size_check_interval}

line_count=0

check_size() {
    (( line_count++ < check_interval )) && return
    line_count=0

    local size
    size=$(stat -c%s "$logfile" 2>/dev/null || echo 0)
    if (( size >= max_size )); then
        local ts
        ts=$(date +%Y%m%d_%H%M%S)
        local rotated="${logfile%.log}.${ts}.log"
        cp "$logfile" "$rotated"
        : > "$logfile"
        display_message "$logfile -> $rotated ($((size / 1024)) KiB)"
    fi
}

# Read stdin and append to log file
while IFS= read -r line; do
    echo "$line" | ansifilter >> "$logfile"
    check_size
done
