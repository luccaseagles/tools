#!/bin/bash

capture_output() {
    # Create the log file only once per session
    if [[ -z "$LOG_CAPTURE_FILE" ]]; then
        local timestamp
        timestamp=$(date '+%Y%m%d-%H%M%S')
        local hostname
        hostname=$(hostname)
        export LOG_CAPTURE_FILE="$LOG_CAPTURE_DIR/logs-${hostname}-${timestamp}.md"
        echo "Logging to $LOG_CAPTURE_FILE"
    fi

    # Capture the last command
    history 1 | sed 's/^[ ]*[0-9]*[ ]*//' > /tmp/last_cmd
    local cmd
    cmd=$(cat /tmp/last_cmd)

    # Run the command and capture output
    local tmp_output
    tmp_output=$(eval "$cmd" 2>&1)

    # Append formatted output to the log file
    {
        echo "Run,"
        echo '```'
        echo "$cmd"
        echo '```'
        echo "Returns,"
        echo '```'
        echo "$tmp_output" | tail -n 10
        echo '```'
        echo
    } >> "$LOG_CAPTURE_FILE"
}

capture() {
    export LOG_CAPTURE_DIR="$(pwd)"
    export PROMPT_COMMAND='capture_output'
    echo "Output capture activated. Logs will be written to: $LOG_CAPTURE_DIR/logs-\$hostname-\$timestamp.md"
}

stop_capture() {
    unset PROMPT_COMMAND
    unset LOG_CAPTURE_FILE
    unset LOG_CAPTURE_DIR
    echo "Output capture deactivated."
}
