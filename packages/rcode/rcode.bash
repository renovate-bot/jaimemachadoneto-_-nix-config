#! /bin/bash

max_retry=10

for i in $(seq 1 $max_retry); do
    # shellcheck disable=SC2012
    recent_folder=$(ls -d ~/.vscode-server/cli/servers/*/ -t | head -n1 | tail -1)
    # shellcheck disable=SC2116
    script=$(echo "$recent_folder/server/bin/remote-cli/code")
    if [[ -z ${script} ]]; then
        echo "VSCode remote script not found"
        exit 1
    fi
    # shellcheck disable=SC2012
    # shellcheck disable=SC2086
    socket=$(ls /run/user/$UID/vscode-ipc-* -t | head -n$i | tail -1)
    if [[ -z ${socket} ]]; then
        echo "VSCode IPC socket not found"
        exit 1
    fi
    export VSCODE_IPC_HOOK_CLI=${socket}
    ${script} "$@" 2>/dev/null
    # shellcheck disable=SC2181
    if [ "$?" -eq "0" ]; then
        exit 0
    fi
done

echo "Failed to find valid VS Code window"
