#!/usr/bin/env bash

set -euo pipefail

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Check if running in WSL2
if grep -qi microsoft /proc/version; then
    echo "WSL2 detected, checking systemd configuration..."

    # Check if systemd is already configured
    if [ ! -f "/etc/wsl.conf" ] || ! grep -q "systemd=true" "/etc/wsl.conf"; then
        echo "Configuring systemd..."
        # Configure WSL to use systemd
        cat > /etc/wsl.conf << EOF
[boot]
systemd=true
EOF
        # Notify user to restart WSL
        echo "systemd has been enabled in WSL2."
        echo "Please restart WSL by running this command in PowerShell (as Administrator):"
        echo "wsl --shutdown"
        echo "Then reopen your WSL terminal."
        exit 0
    else
        echo "systemd already configured, continuing with setup..."
    fi
else
    echo "Not running in WSL2, skipping systemd configuration"
fi

# Get arguments
USERNAME=${1:-$SUDO_USER}
USER_ID=$(id -u "$USERNAME")
GROUP_ID=$(id -g "$USERNAME")
HOSTNAME=$(hostname)

# Install required packages
apt-get update 
apt-get install -y \
    curl \
    xz-utils \
    sudo \
    git \
    vim \
    systemd

# Ensure systemd is running
if ! systemctl status systemd > /dev/null 2>&1; then
    echo "Starting systemd..."
    systemctl start systemd || {
        echo "Failed to start systemd"
        exit 1
    }
fi

# Setup user if needed
if getent group "$GROUP_ID" > /dev/null 2>&1; then
    groupmod -n "$USERNAME" "$(getent group "$GROUP_ID" | cut -d: -f1)"
else
    groupadd -g "$GROUP_ID" "$USERNAME"
fi

if id -u "$USER_ID" > /dev/null 2>&1; then
    usermod -l "$USERNAME" -d "/home/$USERNAME" -m "$(id -nu "$USER_ID")"
else
    useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/bash "$USERNAME"
fi

# Add sudo privileges
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Configure Nix
mkdir -p /etc/nix
cat > /etc/nix/nix.conf << EOF
experimental-features = nix-command flakes
allow-import-from-derivation = true
substituters = https://cache.nixos.org https://cache.garnix.io
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
EOF

# Set ownership
chown --recursive "$USERNAME" /nix

# Set hostname
echo "$HOSTNAME" > /etc/hostname

echo "Environment setup complete for $USERNAME"
