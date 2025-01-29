#!/bin/bash

# Update the system
sudo apt update && sudo apt upgrade -y

# Install required dependencies
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update package index again and install Docker CE
sudo apt update
sudo apt install -y docker-ce

# Start and enable Docker
# sudo systemctl enable docker
# sudo systemctl start docker

# Add the user to Docker group to run without sudo
sudo usermod -aG docker $USER

# Print Docker version
docker --version

# Test Docker installation
docker run hello-world

echo "Docker installation completed successfully!"
