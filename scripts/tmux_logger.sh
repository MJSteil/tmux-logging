#!/bin/bash

set -euo pipefail

logfile="$1"
maxsize_kib="${2:-1}"             # e.g. 1 = 1 KiB
maxsize_bytes=$((maxsize_kib * 1024))
check_interval="${3:-10}" # optional, default = 10
line_count=0


check_size() {
    (( line_count++ < check_interval )) && return
    line_count=0

    local size
    size=$(stat -c%s "$logfile" 2>/dev/null || echo 0)
    if (( size >= maxsize_bytes )); then
        local ts
        ts=$(date +%Y%m%d_%H%M%S)
        local rotated="${logfile}.${ts}"
        cp "$logfile" "$rotated"
        : > "$logfile"
    fi
}


# Read stdin and append to log file
while IFS= read -r line; do
    echo "$line" | ansifilter >> "$logfile"
    check_size
done
