#!/bin/bash
# filepath: install-nix-direnv.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running in WSL
check_wsl() {
    if ! (grep -qi "microsoft\|wsl" /proc/version 2>/dev/null || [ -n "$WSL_DISTRO_NAME" ]); then
        print_error "This script is designed for WSL. Please run it inside WSL."
        exit 1
    fi
    print_success "Running in WSL environment"
}
# Install Nix
install_nix() {
    print_status "Installing Nix package manager..."
    
    # Check if Nix is already installed
    if command -v nix >/dev/null 2>&1; then
        print_warning "Nix is already installed"
        nix --version
        return 0
    fi
    
    # Install Nix using the official installer
    print_status "Downloading and installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
    
    print_success "Nix installation completed"
}

# Setup Nix environment
setup_nix_environment() {
    print_status "Setting up Nix environment..."
    
    # Source Nix profile if it exists
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        source ~/.nix-profile/etc/profile.d/nix.sh
    fi
    
    # Add nixpkgs channel
    print_status "Adding nixpkgs channel..."
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
    nix-channel --update
    
    print_success "Nix environment setup completed"
}

# Configure Nix with flakes support
configure_nix() {
    print_status "Configuring Nix with experimental features..."
    
    # Create nix config directory
    mkdir -p ~/.config/nix
    
    # Enable flakes and nix-command
    if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        print_success "Enabled experimental features (flakes and nix-command)"
    else
        print_warning "Experimental features already configured"
    fi
}

# Install direnv
install_direnv() {
    print_status "Installing direnv..."
    
    # Check if direnv is already installed
    if command -v direnv >/dev/null 2>&1; then
        print_warning "direnv is already installed"
        direnv version
    else
        # Install direnv using Nix
        nix-env -iA nixpkgs.direnv
        print_success "direnv installed successfully"
    fi
    
    # Install nix-direnv
    print_status "Installing nix-direnv..."
    if nix-env -q | grep -q nix-direnv; then
        print_warning "nix-direnv is already installed"
    else
        nix-env -iA nixpkgs.nix-direnv
        print_success "nix-direnv installed successfully"
    fi
}

# Configure direnv
configure_direnv() {
    print_status "Configuring direnv..."
    
    # Create direnv config directory
    mkdir -p ~/.config/direnv
    
    # Add direnv hook to bashrc if not already present
    if ! grep -q "direnv hook bash" ~/.bashrc 2>/dev/null; then
        echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
        print_success "Added direnv hook to ~/.bashrc"
    else
        print_warning "direnv hook already exists in ~/.bashrc"
    fi
    
    # Configure direnv to work with nix-direnv
    if [ -f ~/.nix-profile/share/nix-direnv/direnvrc ]; then
        if ! grep -q "nix-direnv/direnvrc" ~/.config/direnv/direnvrc 2>/dev/null; then
            echo 'source ~/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc
            print_success "Configured direnv to use nix-direnv"
        else
            print_warning "nix-direnv already configured"
        fi
    else
        # Fallback configuration
        if ! grep -q "use_nix" ~/.config/direnv/direnvrc 2>/dev/null; then
            echo 'use_nix() { nix-shell "$@"; }' >> ~/.config/direnv/direnvrc
            print_success "Added basic nix support to direnv"
        fi
    fi
    
    # Create direnv.toml configuration
    if [ ! -f ~/.config/direnv/direnv.toml ]; then
        cat > ~/.config/direnv/direnv.toml << EOF
[global]
hide_env_diff = true
warn_timeout = "30s"
EOF
        print_success "Created direnv.toml configuration"
    else
        print_warning "direnv.toml already exists"
    fi
}

# Verify installations
verify_installations() {
    print_status "Verifying installations..."
    
    # Source the updated profile
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        source ~/.nix-profile/etc/profile.d/nix.sh
    fi
    
    # Test Nix
    if command -v nix >/dev/null 2>&1; then
        print_success "Nix is working: $(nix --version)"
        
        # Test a simple package installation
        print_status "Testing Nix with hello package..."
        if nix-shell -p hello --run "hello" >/dev/null 2>&1; then
            print_success "Nix package installation test passed"
        else
            print_warning "Nix package test failed, but Nix is installed"
        fi
    else
        print_error "Nix verification failed"
        return 1
    fi
    
    # Test direnv
    if command -v direnv >/dev/null 2>&1; then
        print_success "direnv is working: $(direnv version)"
    else
        print_error "direnv verification failed"
        return 1
    fi
}

# Create example project
create_example_project() {
    print_status "Creating example project..."
    
    EXAMPLE_DIR="$HOME/nix-direnv-example"
    mkdir -p "$EXAMPLE_DIR"
    cd "$EXAMPLE_DIR"
    
    # Create shell.nix
    cat > shell.nix << 'EOF'
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nodejs
    python3
    git
    curl
  ];
  
  shellHook = ''
    echo "Welcome to your Nix development environment!"
    echo "Available tools: nodejs, python3, git, curl"
  '';
}
EOF
    
    # Create .envrc
    cat > .envrc << 'EOF'
use nix
export PROJECT_NAME="nix-direnv-example"
export NODE_ENV="development"
EOF
    
    print_success "Example project created at $EXAMPLE_DIR"
    print_status "To use it:"
    echo "  cd $EXAMPLE_DIR"
    echo "  direnv allow"
}


# Install Zscaler Certificate
install_zscaler_cert() {
    print_status "Installing Zscaler certificate..."
    
    # Download the certificate
    print_status "Downloading Zscaler certificate..."
    if curl -sSL "https://raw.github.azc.ext.hp.com/gist/jaime-machado-neto/367322e3974fe97dbbae418770c6804a/raw/61c43ef225adbb58221be22ec81128a21a8aab5e/zscaler-root.pem?token=AAABR2DUFRKBQKBLNB3BWATIRHNKA" -o zscaler-root.pem; then
        print_success "Certificate downloaded successfully"
    else
        print_error "Failed to download Zscaler certificate"
        return 1
    fi
    
    # Install the certificate system-wide
    print_status "Installing certificate system-wide..."
    sudo cp zscaler-root.pem /usr/local/share/ca-certificates/zscaler-root.crt
    
    # Update certificate store
    print_status "Updating certificate store..."
    sudo update-ca-certificates
    
    # Clean up downloaded file
    rm -f zscaler-root.pem
    
    # Verify certificate installation
    if [ -f /usr/local/share/ca-certificates/zscaler-root.crt ]; then
        print_status "Verifying certificate installation..."
        
        # Extract the subject or a unique identifier from the certificate
        CERT_SUBJECT=$(openssl x509 -in /usr/local/share/ca-certificates/zscaler-root.crt -noout -subject 2>/dev/null | cut -d'=' -f2- | xargs)
        
        if [ -n "$CERT_SUBJECT" ]; then
            # Check if the certificate subject/content is in the CA bundle
            if openssl x509 -in /etc/ssl/certs/ca-certificates.crt -noout -text 2>/dev/null | grep -q "$CERT_SUBJECT"; then
                print_success "Zscaler certificate verified in CA bundle"
            else
                # Alternative check: compare certificate fingerprints
                CERT_FINGERPRINT=$(openssl x509 -in /usr/local/share/ca-certificates/zscaler-root.crt -noout -fingerprint -sha256 2>/dev/null | cut -d'=' -f2)
                if [ -n "$CERT_FINGERPRINT" ] && grep -q "$CERT_FINGERPRINT" /etc/ssl/certs/ca-certificates.crt 2>/dev/null; then
                    print_success "Zscaler certificate verified in CA bundle (by fingerprint)"
                else
                    print_warning "Certificate installed but verification failed - this may be normal"
                fi
            fi
        else
            print_warning "Could not extract certificate details for verification"
        fi
        
        # Test HTTPS connection to verify it's working
        print_status "Testing HTTPS connection..."
        if curl -sSL https://www.google.com > /dev/null 2>&1; then
            print_success "HTTPS connection test passed"
        else
            print_warning "HTTPS connection test failed, but certificate is installed"
        fi
    else
        print_error "Certificate installation verification failed - file not found"
        return 1
    fi
}

# Main installation function
main() {
    print_status "Starting Nix and direnv installation..."
    
    # Check prerequisites
    check_wsl
    
    # Install Zscaler certificate
    
    # Install and configure Nix
    install_nix
    setup_nix_environment
    configure_nix
    
    # Install and configure direnv
    install_direnv
    configure_direnv
    
    # Verify everything works
    verify_installations
    
    # Create example project
    create_example_project
    
    print_success "Installation completed successfully!"
    print_status "Please restart your shell or run: source ~/.bashrc"
    print_status "Then you can test the example project at: $HOME/nix-direnv-example"
}


# Run main function
main "$@"
