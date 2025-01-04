#!/bin/bash

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$REPO_DIR/dotfiles"
CONFIG_DIR="$REPO_DIR/configs"

# Files to track
declare -A files=(
    ["$DOTFILES_DIR/.zshrc"]="$HOME/.zshrc"
    ["$DOTFILES_DIR/.tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES_DIR/.gitconfig"]="$HOME/.gitconfig"
)

# Config directories to track
declare -A configs=(
    ["$CONFIG_DIR/sway"]="$HOME/.config/sway"
    ["$CONFIG_DIR/waybar"]="$HOME/.config/waybar"
    ["$CONFIG_DIR/nvim"]="$HOME/.config/nvim"
)

# Create directories if they don't exist
for dest in "${configs[@]}"; do
    mkdir -p "$(dirname "$dest")"
done

# Compare and sync single files
for src in "${!files[@]}"; do
    dest="${files[$src]}"
    if [ -f "$src" ]; then
        if ! cmp -s "$src" "$dest"; then
            echo "Updating $dest"
            cp "$src" "$dest"
        fi
    else
        echo "Warning: Source file $src does not exist"
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
    else
        echo "Warning: Source directory $src does not exist"
    fi
done

echo "Sync complete"
