#!/bin/bash
# Cleanup script to remove Chezmoi-managed files for Home Manager testing
# This script backs up existing files before removing them

set -euo pipefail

BACKUP_DIR="$HOME/.chezmoi-backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup_and_remove() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    echo "Backing up and removing: $target"
    mv "$target" "$BACKUP_DIR/"
  else
    echo "Skipping (not found): $target"
  fi
}

# Chezmoi-managed files in $HOME
backup_and_remove "$HOME/.zshrc"
backup_and_remove "$HOME/.zsh.d"
backup_and_remove "$HOME/.gitconfig"
backup_and_remove "$HOME/.default-npm-packages"
backup_and_remove "$HOME/.claude"
backup_and_remove "$HOME/bin"

# Chezmoi-managed files in ~/.config
backup_and_remove "$HOME/.config/aquaproj-aqua"
backup_and_remove "$HOME/.config/claude"
backup_and_remove "$HOME/.config/git"
backup_and_remove "$HOME/.config/mise"
backup_and_remove "$HOME/.config/nvim"

# Installed by Chezmoi scripts
backup_and_remove "$HOME/.zplug"
backup_and_remove "$HOME/.local/bin/mise"
backup_and_remove "$HOME/.local/share/mise"

# Note: GPG keys are NOT removed. Remove manually if needed:
#   gpg --delete-secret-keys <email>
#   gpg --delete-keys <email>

# Home Manager managed files (in case of re-testing)
backup_and_remove "$HOME/.config/zsh"

# Remove Home Manager generations link if exists
backup_and_remove "$HOME/.local/state/nix/profiles/home-manager"
backup_and_remove "$HOME/.local/state/home-manager"

echo ""
echo "Cleanup complete!"
echo "Backup stored in: $BACKUP_DIR"
echo ""
echo "To restore, run:"
echo "  cp -r $BACKUP_DIR/. $HOME/"
