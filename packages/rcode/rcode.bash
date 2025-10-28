#!/bin/bash
# This script runs on the REMOTE box

WSL_HOST="localhost"  # This works through the reverse tunnel
WSL_PORT=9999

# Detect the SSH connection string to identify this host
# This will be sent to WSL so it knows which host to connect to
if [ -n "$SSH_CONNECTION" ]; then
    # Get the username and hostname
    CURRENT_USER=$(whoami)
    CURRENT_HOST=$(hostname -f 2>/dev/null || hostname)
    SSH_IDENTIFIER="${CURRENT_USER}@${CURRENT_HOST}"
else
    echo "Warning: Not in an SSH session, using fallback identifier"
    SSH_IDENTIFIER="$(whoami)@$(hostname)"
fi

if [ $# -eq 0 ]; then
    echo "Usage: rcode <file or folder>"
    echo "Example: rcode /etc/nginx/nginx.conf"
    echo "Example: rcode ."
    echo ""
    echo "This host will be identified as: $SSH_IDENTIFIER"
    exit 1
fi

TARGET="$1"

# Convert to absolute path
if [ -d "$TARGET" ]; then
    ABS_PATH=$(cd "$TARGET" && pwd)
elif [ -f "$TARGET" ]; then
    ABS_PATH=$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")
else
    echo "Error: $TARGET does not exist"
    exit 1
fi

echo "Host identifier: $SSH_IDENTIFIER"
echo "Sending request to open: $ABS_PATH"

# Send the host and path through the reverse tunnel to WSL
# Format: HOSTNAME|PATH

if printf "%s|%s\n" "$SSH_IDENTIFIER" "$ABS_PATH" | nc -N "$WSL_HOST" "$WSL_PORT"; then
    echo "Request sent successfully"
else
    echo "Error: Could not connect to WSL listener"
    echo "Make sure the reverse SSH tunnel is active"
    exit 1
fi
