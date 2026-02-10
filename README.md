# dotfiles

nownabe's dotfiles. Manages user configurations for Ubuntu (x86_64-linux), supporting both native Ubuntu and WSL2.

Managed by [Nix Home Manager](https://nix-community.github.io/home-manager/) (Flake-based standalone).

## Setup

```shell
curl -fsSL https://raw.githubusercontent.com/nownabe/dotfiles/main/setup.sh | bash
```

This will:

1. Install Nix via [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)
2. Clone this repository to `~/src/github.com/nownabe/dotfiles`
3. Apply Home Manager configuration (auto-detects WSL vs native Linux)
4. Set Zsh as the default shell

## Applying Changes

```shell
hms
```

The `hms` alias automatically selects the correct Flake entrypoint (`wsl` or `linux`).

## Directory Structure

```
dotfiles/
├── flake.nix       # Nix Flake entry point (wsl / linux configs)
├── home.nix        # Home Manager configuration
├── programs/       # Modular configurations
│   ├── zsh/        # Zsh
│   ├── git/        # Git
│   ├── nvim/       # Neovim (AstroNvim)
│   └── claude/     # Claude Code
├── setup.sh        # Bootstrap script
└── scripts/        # Utility scripts
```

## Manual Setup

### Font

Install [UbuntuSansMono Nerd Font](https://www.nerdfonts.com/font-downloads) (`UbuntuSansMono Nerd Font Mono`).

### WSL

- Remove the `Ctrl+V` keybinding in Windows Terminal. Use `Ctrl+Shift+V` to paste instead.
