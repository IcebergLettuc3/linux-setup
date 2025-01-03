#!/bin/bash

set -e

INSTALL_DIR="$HOME/.local/share/orcaslicer"
BIN_DIR="$HOME/.local/bin"

# Create directories
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Get latest release URL
LATEST_URL=$(curl -s https://api.github.com/repos/SoftFever/OrcaSlicer/releases/latest \
    | grep "browser_download_url.*OrcaSlicer_Linux_V.*AppImage" \
    | cut -d '"' -f 4 \
    | head -n 1)

echo "Debug: Found URL is: $LATEST_URL"

# Verify URL
if [ -z "$LATEST_URL" ]; then
    echo "Error: Failed to fetch the latest release URL."
    exit 1
fi

# Download and extract
echo "Downloading OrcaSlicer from $LATEST_URL..."
wget -O /tmp/orcaslicer.AppImage "$LATEST_URL"
trap 'rm -f /tmp/orcaslicer.AppImage' EXIT

# Move to install directory
echo "Installing OrcaSlicer to $INSTALL_DIR..."
mv /tmp/orcaslicer.AppImage "$INSTALL_DIR/orcaslicer.AppImage"
chmod +x "$INSTALL_DIR/orcaslicer.AppImage"

# Create symlink
ln -sf "$INSTALL_DIR/orcaslicer.AppImage" "$BIN_DIR/orcaslicer"
echo "Symlink created at $BIN_DIR/orcaslicer."

# PATH Reminder
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "Warning: $BIN_DIR is not in your PATH."
    echo "Add it by running: export PATH=\"$BIN_DIR:\$PATH\""
fi

echo "OrcaSlicer installed successfully."
