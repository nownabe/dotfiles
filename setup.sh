#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

DOTFILES_REPO="https://github.com/nownabe/dotfiles.git"
DOTFILES_DIR="$HOME/src/github.com/nownabe/dotfiles"
DOTFILES_LINK="$HOME/.dotfiles"

# 1. Install Nix
if command -v nix &>/dev/null; then
  echo "Nix is already installed, skipping."
else
  echo "Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
fi

# 2. Source Nix environment if not yet in PATH
if ! command -v nix &>/dev/null; then
  echo "Sourcing Nix environment..."
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 3. Clone dotfiles
if [ -d "$DOTFILES_DIR" ]; then
  echo "Dotfiles already cloned at $DOTFILES_DIR, skipping."
else
  echo "Cloning dotfiles to $DOTFILES_DIR..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# 4. Create symlink
if [ -e "$DOTFILES_LINK" ]; then
  echo "$DOTFILES_LINK already exists, skipping."
else
  echo "Creating symlink $DOTFILES_LINK -> $DOTFILES_DIR..."
  ln -s "$DOTFILES_DIR" "$DOTFILES_LINK"
fi

# 5. Detect environment
if grep -qi microsoft /proc/version 2>/dev/null; then
  HM_CONFIG="wsl"
else
  HM_CONFIG="linux"
fi

# 6. Apply Home Manager
echo "Applying Home Manager configuration ($HM_CONFIG)..."
nix run home-manager -- switch --flake "$DOTFILES_LINK#$HM_CONFIG"

# 7. Set zsh as default shell
ZSH_PATH="$HOME/.nix-profile/bin/zsh"
if [ -x "$ZSH_PATH" ]; then
  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$ZSH_PATH"
  fi
fi

echo "Done!"
