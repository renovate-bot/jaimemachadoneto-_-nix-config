# syntax=docker/dockerfile:1.4

FROM ubuntu:22.04

# Accept build arguments for UID/GID
ARG HOSTNAME
ARG USER_ID
ARG GROUP_ID
ARG USERNAME


# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
    sudo \
    git \
    vim \
    systemd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon


# Create/modify user and group
RUN if getent group $GROUP_ID > /dev/null 2>&1; then \
    groupmod -n $USERNAME $(getent group $GROUP_ID | cut -d: -f1); \
    else \
    groupadd -g $GROUP_ID $USERNAME; \
    fi && \
    if id -u $USER_ID > /dev/null 2>&1; then \
    usermod -l $USERNAME -d /home/$USERNAME -m $(id -nu $USER_ID); \
    else \
    useradd -u $USER_ID -g $GROUP_ID -m -s /bin/bash $USERNAME; \
    fi && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN chown --recursive $USERNAME /nix

# Setup environment
ENV USER=$USERNAME
ENV SHELL=/bin/bash

# Set hostname properly
RUN echo "$HOSTNAME" > /etc/hostname

# Install Nix
RUN  mkdir -p /etc/nix
RUN  echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
RUN  echo "allow-import-from-derivation = true" >> /etc/nix/nix.conf
RUN  echo "substituters = https://cache.nixos.org https://cache.garnix.io" >> /etc/nix/nix.conf
RUN  echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" >> /etc/nix/nix.conf

USER $USERNAME
WORKDIR /home/$USERNAME/
# Configure Nix
# RUN mkdir -p ~/.config/nix
# RUN echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
# RUN echo "allow-import-from-derivation = true" >> ~/.config/nix/nix.conf
# RUN echo "substituters = https://cache.nixos.org https://cache.garnix.io" >> ~/.config/nix/nix.conf
# RUN echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" >> ~/.config/nix/nix.conf


# Create entrypoint script
RUN echo '#!/bin/sh\n\
    exec /bin/bash' > /home/$USERNAME/entrypoint.sh && \
    chmod +x /home/$USERNAME/entrypoint.sh


# Use shell form to allow variable expansion
ENTRYPOINT exec /home/${USER}/entrypoint.sh
