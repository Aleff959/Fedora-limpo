#!/bin/bash

# Set strict error handling
set -euo pipefail

# Configuration
LOG_FILE="/var/log/fedora_setup.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Trap ctrl-c and call cleanup
trap cleanup INT

# Logging functions
log() {
    echo "[${TIMESTAMP}] $1" >> "${LOG_FILE}"
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo "[${TIMESTAMP}] ERROR: $1" >> "${LOG_FILE}"
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warn() {
    echo "[${TIMESTAMP}] WARNING: $1" >> "${LOG_FILE}"
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# System check functions
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (sudo)"
    fi
}

check_success() {
    if [ $? -ne 0 ]; then
        error "Failed to execute: $1"
    fi
}

check_fedora() {
    if [ ! -f /etc/fedora-release ]; then
        error "This script is designed for Fedora systems only"
    fi
}

# DNF Configuration
configure_dnf() {
    log "Configuring DNF..."
    if ! grep -q "max_parallel_downloads" /etc/dnf/dnf.conf; then
        echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
    fi
    if ! grep -q "fastestmirror" /etc/dnf/dnf.conf; then
        echo "fastestmirror=true" >> /etc/dnf/dnf.conf
    fi
    check_success "DNF Configuration"
}

# System update function
update_system() {
    log "Updating system..."
    dnf update -y
    check_success "System update"
}

# RPM Fusion installation
install_rpmfusion() {
    log "Installing RPM Fusion repositories..."
    dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    check_success "RPM Fusion Free installation"
    dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    check_success "RPM Fusion NonFree installation"
}

# VirtualBox installation
install_virtualbox() {
    log "Installing VirtualBox..."
    dnf install -y @development-tools kernel-devel kernel-headers dkms
    check_success "Development tools installation"
    
    dnf config-manager --add-repo https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo
    check_success "VirtualBox repository addition"
    
    dnf install -y VirtualBox-6.1
    check_success "VirtualBox installation"
    
    # Post-installation setup
    usermod -a -G vboxusers $SUDO_USER
    systemctl enable vboxdrv
    systemctl start vboxdrv
    check_success "VirtualBox post-installation setup"
}

# Warp Terminal installation
install_warp() {
    log "Installing Warp Terminal..."
    if command -v rpm-ostree &> /dev/null; then
        warn "System appears to be using rpm-ostree. Warp installation might not work as expected."
    fi
    curl -fsSL https://app.warp.dev/download/dnf.rpm > warp.rpm
    dnf install -y ./warp.rpm
    rm -f warp.rpm
    check_success "Warp Terminal installation"
}

# Stremio installation
install_stremio() {
    log "Installing Stremio..."
    dnf install -y dnf-plugins-core
    dnf config-manager --add-repo https://www.stremio.com/downloads/server/dnf/stremio.repo
    dnf install -y stremio
    check_success "Stremio installation"
}

# Telegram installation
install_telegram() {
    log "Installing Telegram..."
    dnf install -y telegram-desktop
    check_success "Telegram installation"
}

# Spotify installation
install_spotify() {
    log "Installing Spotify..."
    dnf config-manager --add-repo=https://negativo17.org/repos/fedora-spotify.repo
    dnf install -y spotify-client
    check_success "Spotify installation"
}

# Microsoft Fonts installation
install_msfonts() {
    log "Installing Microsoft Fonts..."
    dnf install -y cabextract xorg-x11-font-utils fontconfig
    rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
    check_success "Microsoft Fonts installation"
}

# Cleanup function
cleanup() {
    log "Performing cleanup..."
    dnf clean all
    rm -f warp.rpm 2>/dev/null || true
    check_success "Cleanup completed"
}

# Main execution
main() {
    # Initialize log file
    touch "${LOG_FILE}"
    chmod 644 "${LOG_FILE}"

    # System checks
    check_root
    check_fedora
    
    # Basic setup
    configure_dnf
    update_system
    install_rpmfusion

    # Install applications
    install_virtualbox
    install_warp
    install_stremio
    install_telegram
    install_spotify
    install_msfonts

    # Final cleanup
    cleanup

    log "Setup completed successfully!"
}

# Execute main function
main "$@"

