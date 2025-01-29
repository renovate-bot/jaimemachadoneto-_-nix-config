# syntax=docker/dockerfile:1.4

FROM ubuntu:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
    sudo \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash nixuser && \
    echo "nixuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Nix
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Configure Nix
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf && \
    echo "substituters = https://cache.nixos.org https://cache.garnix.io" >> /etc/nix/nix.conf && \
    echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" >> /etc/nix/nix.conf && \
    chown -R nixuser:nixuser /nix

# Setup environment
ENV USER=nixuser
ENV NIX_PROFILES="/nix/var/nix/profiles/default"
ENV PATH="/nix/var/nix/profiles/default/bin:$PATH"

WORKDIR /workspace

# Create entrypoint script
RUN echo '#!/bin/sh\n\
    export NIX_PROFILES="/nix/var/nix/profiles/default"\n\
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"\n\
    sudo chown $(id -u):$(id -g) /workspace\n\
    sudo chmod 755 /workspace\n\
    sudo -E nix flake check\n\
    sudo -E nix run home-manager -- build --flake .\n\
    sudo -E nixci build' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

USER nixuser
ENTRYPOINT ["/entrypoint.sh"]
