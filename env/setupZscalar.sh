#!/bin/bash
# filepath: /home/jaime/Projects/nix-config/env/setupZscalar.sh

set -e  # Exit on any error

# Colors for prettier output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

echo -e "${GREEN}Starting Zscalar Root Certificate Installation${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root (use sudo)${NC}"
  exit 1
fi

# Verify the certificate was downloaded
if [ ! -f zscaler-root.pem ]; then
  echo -e "${RED}Failed to download Zscalar certificate${NC}"
  exit 1
fi

# Install the certificate to system trust store
echo -e "${YELLOW}Installing certificate to system trust store...${NC}"

# Copy to trusted CA directory
cp zscaler-root.pem /usr/local/share/ca-certificates/zscaler-root.crt

# Update CA certificates
update-ca-certificates

echo -e "${GREEN}Zscalar root certificate has been installed successfully!${NC}"
