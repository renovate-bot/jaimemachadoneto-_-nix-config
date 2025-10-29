#!/bin/bash
# =============================================================================
# PART 1: Script to run on WSL (listener service)
# Save as: ~/remote-vscode-listener.sh
# =============================================================================
# This script listens for commands from the remote box and opens VS Code
# Run this in a tmux/screen session or as a background service

LISTEN_PORT=9999
PIDFILE="/tmp/remote-vscode-listener.pid"

# Check if PID file exists
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    # Check if process is actually running
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "Script is already running with PID: $PID"
        exit 1
    else
        # PID file exists but process is not running (stale PID file)
        echo "Removing stale PID file"
        rm -f "$PIDFILE"
    fi
fi

# Create PID file with current process ID
echo $$ > "$PIDFILE"

# Cleanup function to remove PID file on exit
cleanup() {
    echo ""
    echo "[$(date)] Shutting down listener..."
    rm -f "$PIDFILE"
    exit 0
}
trap cleanup EXIT INT TERM

echo "Remote VS Code listener starting on port ${LISTEN_PORT}..."
echo "Running with PID: $$"
echo "Waiting for commands from remote host..."
echo ""

while true; do
    # Listen for incoming connection (OpenBSD nc syntax)
    DATA=$(nc -l ${LISTEN_PORT})

    if [ -n "$DATA" ]; then
        # Parse the data: format is "HOSTNAME|TYPE|PATH"
        REMOTE_HOST=$(echo "$DATA" | cut -d'|' -f1)
        ITEM_TYPE=$(echo "$DATA" | cut -d'|' -f2)
        REMOTE_PATH=$(echo "$DATA" | cut -d'|' -f3)

        echo "[$(date)] Received from: $REMOTE_HOST"
        echo "[$(date)] Type: $ITEM_TYPE"
        echo "[$(date)] Path: $REMOTE_PATH"

        # Execute different commands based on type
        if [ "$ITEM_TYPE" = "folder" ]; then
            # Open folder/workspace
            code --folder-uri "vscode-remote://ssh-remote+${REMOTE_HOST}${REMOTE_PATH}" &
            echo "[$(date)] Opened folder in VS Code"
        elif [ "$ITEM_TYPE" = "file" ]; then
            # Open specific file
            code --file-uri "vscode-remote://ssh-remote+${REMOTE_HOST}${REMOTE_PATH}" &
            echo "[$(date)] Opened file in VS Code"
        else
            echo "[$(date)] Unknown type: $ITEM_TYPE"
        fi

        echo ""
    fi
done
