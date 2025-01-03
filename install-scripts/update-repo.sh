#!/bin/bash

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$REPO_DIR/dotfiles"
CONFIG_DIR="$REPO_DIR/configs"

# Files to track
declare -A files=(
    ["$HOME/.zshrc"]="$DOTFILES_DIR/.zshrc"
    ["$HOME/.tmux.conf"]="$DOTFILES_DIR/.tmux.conf"
    ["$HOME/.gitconfig"]="$DOTFILES_DIR/.gitconfig"
)

# Config directories to track
declare -A configs=(
    ["$HOME/.config/sway"]="$CONFIG_DIR/sway"
    ["$HOME/.config/waybar"]="$CONFIG_DIR/waybar"
    ["$HOME/.config/nvim"]="$CONFIG_DIR/nvim"
)

# Create directories if they don't exist
mkdir -p "$DOTFILES_DIR" "$CONFIG_DIR"

# Compare and sync single files
for src in "${!files[@]}"; do
    dest="${files[$src]}"
    if [ -f "$src" ]; then
        if ! cmp -s "$src" "$dest"; then
            echo "Updating $dest"
            cp "$src" "$dest"
        fi
    fi
done

# Compare and sync config directories
for src in "${!configs[@]}"; do
    dest="${configs[$src]}"
    if [ -d "$src" ]; then
        mkdir -p "$dest"
        if ! diff -r "$src" "$dest" >/dev/null 2>&1; then
            echo "Updating $dest"
            rsync -av --delete "$src/" "$dest/"
        fi
    fi
done

echo "Sync complete"
