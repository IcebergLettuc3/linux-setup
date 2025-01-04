#!/bin/bash

set -e

# Verify we're on Debian
if ! command -v apt &>/dev/null; then
    echo "This script requires apt package manager (Debian/Ubuntu)"
    exit 1
fi

# Check for sudo privileges
if ! sudo -v; then
    echo "This script requires sudo privileges"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
DOTFILES_DIR="$REPO_ROOT/dotfiles"
CONFIGS_DIR="$REPO_ROOT/configs"

# Install required packages
echo "Installing required packages..."
sudo apt update
sudo apt install -y \
    sway \
    swaylock \
    waybar \
    swaybg \
    swayidle \
    fonts-font-awesome \
    build-essential \
    git \
    curl \
    btop \
    tmux \
    neovim \
    zsh \
    systemd \
    python3-pip \
    pkg-config \
    pavucontrol \
    libgtk-3-dev \
    libcairo2-dev \
    libpango1.0-dev

# Rest of the functions remain the same
create_symlinks() {
    echo "Creating symlinks..."
    for file in "$DOTFILES_DIR"/.*; do
        if [ -f "$file" ]; then
            basename=$(basename "$file")
            ln -sf "$file" "$HOME/$basename"
        fi
    done
}

setup_configs() {
    echo "Setting up application configs..."
    for app_dir in "$CONFIGS_DIR"/*; do
        if [ -d "$app_dir" ]; then
            app_name=$(basename "$app_dir")
            mkdir -p "$HOME/.config/$app_name"
            ln -sf "$app_dir"/* "$HOME/.config/$app_name/"
        fi
    done
}

setup_services() {
    echo "Setting up systemd services..."
    mkdir -p "$HOME/.config/systemd/user"
    
    cat > "$HOME/.config/systemd/user/swayidle.service" << EOF
[Unit]
Description=Idle manager for Wayland
Documentation=man:swayidle(1)
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 000000'

[Install]
WantedBy=sway-session.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable swayidle.service
}

# Main execution
create_symlinks
setup_configs
setup_services

echo "Setup complete! Please restart your session for all changes to take effect."
