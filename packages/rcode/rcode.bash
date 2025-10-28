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
    echo "Usage: remote_vscode <file or folder>"
    echo "Example: remote_vscode /etc/nginx/nginx.conf"
    echo "Example: remote_vscode ."
    echo ""
    echo "This host will be identified as: $SSH_IDENTIFIER"
    exit 1
fi

TARGET="$1"

# Determine if it's a file or folder and get absolute path
if [ -d "$TARGET" ]; then
    ITEM_TYPE="folder"
    ABS_PATH=$(cd "$TARGET" && pwd)
elif [ -f "$TARGET" ]; then
    ITEM_TYPE="file"
    ABS_PATH=$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")
else
    echo "Error: $TARGET does not exist"
    exit 1
fi

echo "Host identifier: $SSH_IDENTIFIER"
echo "Type: $ITEM_TYPE"
echo "Sending request to open: $ABS_PATH"

# Send the host, type, and path through the reverse tunnel to WSL
# Format: HOSTNAME|TYPE|PATH


if printf "%s|%s|%s\n" "$SSH_IDENTIFIER" "$ITEM_TYPE" "$ABS_PATH" | nc -N "$WSL_HOST" "$WSL_PORT"; then
    echo "Request sent successfully"
else
    echo "Error: Could not connect to WSL listener"
    echo "Make sure the reverse SSH tunnel is active"
    exit 1
fi
