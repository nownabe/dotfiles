# Chezmoi to Home Manager Migration Plan

Detailed plan for migrating all configurations from Chezmoi to Nix Home Manager (Flake-based standalone).

## Current State

- **Home Manager**: `flake.nix` + `home.nix` with minimal config (git, ripgrep packages only)
- **Chezmoi**: Manages zsh, git, neovim, mise, aqua, claude, bin scripts, and system setup scripts
- **Target**: All user configuration managed by Home Manager; Chezmoi fully removed

---

## Phase 1: Packages

Move tool installations currently managed by mise, aqua, and apt to `home.packages`.

### What to Migrate

**From mise (`dot_config/mise/config.toml`):**

| Tool    | Current Version | Nix Package       | Notes                           |
| ------- | --------------- | ----------------- | ------------------------------- |
| aws     | latest          | `awscli2`         |                                 |
| deno    | latest          | `deno`            |                                 |
| fzf     | latest          | `fzf`             |                                 |
| gh      | latest          | `gh`              |                                 |
| ghq     | latest          | `ghq`             |                                 |
| go      | latest          | `go`              |                                 |
| lua     | latest          | `lua`             |                                 |
| node    | lts             | `nodejs_22`       | Use LTS version package         |
| pnpm    | latest          | `pnpm`            |                                 |
| python  | latest          | `python3`         |                                 |
| ripgrep | latest          | `ripgrep`         | Already in home.packages        |
| ruby    | latest          | `ruby`            |                                 |
| uv      | latest          | `uv`              |                                 |
| zoxide  | latest          | `zoxide`          | Use `programs.zoxide` in Phase 2 |
| chezmoi | latest          | —                 | Skip; will be removed           |
| aqua    | latest          | —                 | Skip; will be removed           |

**From aqua (`dot_config/aquaproj-aqua/aqua.yaml`):**

| Tool   | Current Version | Nix Package |
| ------ | --------------- | ----------- |
| bun    | v1.3.4          | `bun`       |
| direnv | v2.37.1         | `direnv`    |
| yq     | v4.50.1         | `yq-go`     |

**From apt (`.chezmoidata/packages.yaml`):**

| Package    | Nix Package    | Notes                            |
| ---------- | -------------- | -------------------------------- |
| apt-file   | —              | Debian-specific, skip            |
| byobu      | `byobu`        |                                  |
| curl       | `curl`         |                                  |
| fzf        | `fzf`          | Duplicate with mise              |
| git        | `git`          | Already in home.packages         |
| gnupg      | `gnupg`        |                                  |
| libyaml-dev| —              | Build dep, add only if needed    |
| wslu       | —              | WSL-specific, not in nixpkgs     |
| zip        | `zip`          |                                  |
| zsh        | `zsh`          | Use `programs.zsh` in Phase 2    |

**Additional tools (from `dot_default-npm-packages`):**

| Package                      | Notes                                |
| ---------------------------- | ------------------------------------ |
| textlint                     | Install via `home.packages` or npm   |
| @anthropic-ai/claude-code    | Install via npm globally             |
| @google/gemini-cli           | Install via npm globally             |
| @openai/codex                | Install via npm globally             |

### How to Implement

Add packages to `home.packages` in `home.nix`:

```nix
home.packages = with pkgs; [
  # Development tools
  awscli2
  bun
  curl
  deno
  direnv
  gh
  ghq
  gnupg
  go
  lua
  nodejs_22
  pnpm
  python3
  ripgrep
  ruby
  uv
  yq-go
  zip

  # Terminal tools
  byobu
  fzf
];
```

For npm global packages, use `home.file` to place `~/.default-npm-packages` or install them separately after node is available.

### Chezmoi Files to Remove

- `dot_config/mise/` (entire directory)
- `dot_config/aquaproj-aqua/` (entire directory)
- `dot_default-npm-packages`

### Dependencies and Blockers

- Verify all packages exist in nixpkgs-unstable
- Some tools (e.g., `wslu`) may not be in nixpkgs; find alternatives or skip
- npm global packages need a strategy (nix-managed node + manual npm install, or nodePackages)

---

## Phase 2: Shell (zsh)

Migrate zsh configuration to `programs.zsh`.

### What to Migrate

**From `dot_zshrc`:**
- zplug plugin manager + plugins
- History settings (1M entries, extended history)
- Shell options (autocd, autopushd, etc.)
- Completion system configuration
- Key bindings
- PATH modifications

**From `dot_zsh.d/`:**

| File              | Content                              | Migration Target                  |
| ----------------- | ------------------------------------ | --------------------------------- |
| `00_aliases.zsh`  | Shell aliases (k, bat, vi, g, etc.)  | `programs.zsh.shellAliases`       |
| `00_mise.zsh`     | Mise activation                      | Remove (mise replaced by Nix)     |
| `00_util.zsh`     | Color echo functions                 | `programs.zsh.initExtra`          |
| `01_aqua.zsh`     | Aqua PATH setup                     | Remove (aqua replaced by Nix)     |
| `01_fzf.zsh`      | FZF config + custom functions        | `programs.fzf` + `initExtra`      |
| `bun.zsh`         | Bun PATH/completions                | Remove (bun managed by Nix)       |
| `git.zsh`         | Git worktree helpers                 | `programs.zsh.initExtra`          |
| `wsl.zsh`         | WSL2 clipboard + DISPLAY            | `programs.zsh.initExtra`          |

**Zsh plugins (currently via zplug):**

| Plugin                              | Home Manager Equivalent                     |
| ----------------------------------- | ------------------------------------------- |
| `sindresorhus/pure`                 | `programs.zsh.plugins` (from nixpkgs `pure-prompt`) |
| `zsh-users/zsh-syntax-highlighting` | `programs.zsh.syntaxHighlighting.enable`    |
| `mafredri/zsh-async`               | Dependency of pure, bundled automatically   |

### How to Implement

```nix
programs.zsh = {
  enable = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;

  history = {
    size = 1000000;
    save = 1000000;
    extended = true;
    ignoreDups = true;
    ignoreAllDups = true;
    share = true;
  };

  shellAliases = {
    k = "kubectl";
    bat = "batcat";
    vi = "nvim";
    g = "git";
    la = "ls -a";
    ll = "ls -l";
    lla = "ls -la";
    bi = "bundle install";
    be = "bundle exec";
    pbcopy = "xsel --clipboard --input";
    open = "xdg-open";
  };

  plugins = [
    {
      name = "pure";
      src = pkgs.pure-prompt;
    }
  ];

  initExtra = ''
    # Shell options
    setopt auto_cd auto_pushd pushd_ignore_dups
    # ... (remaining zshrc content)

    # Custom functions (fzf-ghq, fzf-cdr, gitwt, gitroot)
    # WSL configuration
  '';
};

programs.fzf = {
  enable = true;
  enableZshIntegration = true;
};

programs.zoxide = {
  enable = true;
  enableZshIntegration = true;
};

programs.direnv = {
  enable = true;
  enableZshIntegration = true;
  nix-direnv.enable = true;
};
```

### Chezmoi Files to Remove

- `dot_zshrc`
- `dot_zsh.d/` (entire directory)

### Dependencies and Blockers

- Phase 1 (packages) should be completed first so PATH-dependent configs can be removed
- Need to test that pure prompt works correctly via Home Manager plugin mechanism
- Custom functions (fzf-ghq, fzf-cdr, gitwt) must be preserved in `initExtra`
- WSL-specific config should be conditional (check for WSL environment)

---

## Phase 3: Git

Migrate git configuration to `programs.git`.

### What to Migrate

**From `dot_gitconfig.tmpl`:**
- User name/email
- Aliases (l, co, pp, sw, s, cp)
- Core editor (nvim)
- Init default branch (main)
- Pull rebase, rebase autostash
- ghq root
- GitHub credential helper (gh auth)
- Conditional includes for GitHub GPG signing

**From `dot_config/git/`:**

| File          | Content                        | Migration Target              |
| ------------- | ------------------------------ | ----------------------------- |
| `ignore`      | Global gitignore patterns      | `programs.git.ignores`        |
| `github.tmpl` | GitHub GPG signing config      | `programs.git.signing` + `includes` |

### How to Implement

```nix
programs.git = {
  enable = true;
  userName = "nownabe";
  userEmail = "1286807+nownabe@users.noreply.github.com";

  aliases = {
    l = "log --graph --oneline --all --decorate";
    co = "checkout";
    pp = "pull --prune";
    sw = "switch";
    s = "status";
    cp = "cherry-pick";
  };

  ignores = [
    ".nownabe/"
    ".shogo/"
    ".claude/settings.local.json"
  ];

  extraConfig = {
    core.editor = "nvim";
    init.defaultBranch = "main";
    pull.rebase = true;
    rebase.autostash = true;
    ghq.root = "~/src";
    credential."https://github.com".helper = "!gh auth git-credential";
  };

  signing = {
    key = null;  # Set after GPG key generation
    signByDefault = true;
  };

  includes = [
    {
      condition = "gitdir:~/src/github.com/";
      contents = {
        user.signingkey = "...";  # GPG key ID
        commit.gpgsign = true;
        tag.gpgsign = true;
      };
    }
  ];
};
```

### Chezmoi Files to Remove

- `dot_gitconfig.tmpl`
- `dot_config/git/` (entire directory)

### Dependencies and Blockers

- GPG key generation must be handled (see Phase 6)
- The GPG signing key ID is dynamic (generated per machine); need a strategy:
  - Option A: Use `home.nix` variable populated during bootstrap
  - Option B: Use git conditional include pointing to a local file not managed by Nix
  - Option C: Generate key in activation script and write to a Nix-managed path
- Credential helper depends on `gh` being in PATH (handled by Phase 1)

---

## Phase 4: Neovim

Migrate Neovim configuration using `xdg.configFile`.

### What to Migrate

**From `dot_config/nvim/`:**
- `init.lua` (entry point)
- `lua/config/` (options, keymaps, autocmds, lazy.nvim bootstrap)
- `lua/plugins/` (all plugin specs)
- `lua/utils/` (utility modules)

### How to Implement

Use `xdg.configFile` to symlink the entire nvim directory rather than `programs.neovim`, since the configuration is complex and uses lazy.nvim for plugin management:

```nix
programs.neovim = {
  enable = true;
  defaultEditor = true;
  vimAlias = true;
};

# Symlink the entire nvim config directory
xdg.configFile."nvim" = {
  source = ./nvim;
  recursive = true;
};
```

Move the nvim configuration from `dot_config/nvim/` to a top-level `nvim/` directory in the repository (or keep it under a `config/` directory).

### Chezmoi Files to Remove

- `dot_config/nvim/` (entire directory)

### Dependencies and Blockers

- Neovim and its runtime dependencies (gcc/g++, make for treesitter compilation) must be available
- Mason LSP servers are downloaded at runtime; no Nix change needed for those
- lazy.nvim manages its own plugins at runtime; this is independent of Nix
- Consider whether to add treesitter build dependencies to `home.packages`:
  - `gcc`, `gnumake`, `tree-sitter` (for treesitter parser compilation)

---

## Phase 5: Other Configs

Migrate remaining configuration files.

### What to Migrate

| Source                    | Content                  | Migration Target                      |
| ------------------------- | ------------------------ | ------------------------------------- |
| `dot_config/claude/`      | Claude CLI settings      | `xdg.configFile."claude/settings.json"` |
| `dot_claude/`             | Claude Code settings     | `home.file.".claude/settings.json"` + `home.file.".claude/statusline-command.sh"` |
| `bin/`                    | Custom scripts           | `home.file."bin/*"` with executable bit |

### How to Implement

**Claude CLI config:**

```nix
xdg.configFile."claude/settings.json" = {
  source = ./config/claude/settings.json;
};
```

**Claude Code settings:**

```nix
home.file.".claude/settings.json" = {
  source = ./claude/settings.json;
};

home.file.".claude/statusline-command.sh" = {
  source = ./claude/statusline-command.sh;
  executable = true;
};
```

**Custom bin scripts:**

```nix
home.file."bin/notify-windows" = {
  source = ./bin/notify-windows;
  executable = true;
};

home.file."bin/git-clean-squashed" = {
  source = ./bin/git-clean-squashed;
  executable = true;
};

home.file."bin/git-wt-helper" = {
  source = ./bin/git-wt-helper;
  executable = true;
};
```

Rename source files by removing the `executable_` Chezmoi prefix. Restructure the repository:

```
dotfiles/
├── bin/                    # Renamed from bin/executable_* (drop prefix)
├── claude/                 # From dot_claude/
├── config/
│   └── claude/             # From dot_config/claude/
├── nvim/                   # From dot_config/nvim/ (Phase 4)
├── flake.nix
├── home.nix
└── ...
```

### Chezmoi Files to Remove

- `dot_config/claude/`
- `dot_claude/`
- `bin/` (Chezmoi-prefixed files; replace with plain files)

### Dependencies and Blockers

- Rename `executable_*` files to remove Chezmoi prefix before or during migration
- Ensure `~/bin` is in PATH (configured in Phase 2 shell setup)

---

## Phase 6: Scripts

Migrate or remove Chezmoi run scripts.

### What to Migrate

| Script                                          | Purpose                    | Migration Strategy               |
| ----------------------------------------------- | -------------------------- | -------------------------------- |
| `run_once_02_mise.sh`                           | Install mise               | Remove (replaced by Nix)         |
| `run_once_10_zplug.sh`                          | Clone zplug                | Remove (replaced by Nix plugins) |
| `run_once_before_generate-gpg-key.sh.tmpl`      | Generate GPG key           | Home Manager activation script   |
| `run_once_after_add-gpg-key.sh.tmpl`            | Add GPG key to GitHub      | Home Manager activation script   |
| `run_onchange_before_01_ubuntu-install-packages.sh.tmpl` | Install apt packages | Remove (replaced by Nix)         |

### How to Implement

**GPG key generation** (activation script):

```nix
home.activation.generateGpgKey = lib.hm.dag.entryAfter [ "installPackages" ] ''
  if ! ${pkgs.gnupg}/bin/gpg --list-keys "1286807+nownabe@users.noreply.github.com" > /dev/null 2>&1; then
    ${pkgs.gnupg}/bin/gpg --batch --gen-key <<GPGEOF
      Key-Type: RSA
      Key-Length: 4096
      Subkey-Type: RSA
      Subkey-Length: 4096
      Name-Real: nownabe
      Name-Email: 1286807+nownabe@users.noreply.github.com
      Expire-Date: 0
      %no-protection
    GPGEOF
  fi
'';
```

**GitHub GPG key registration** should remain a manual step or a separate bootstrap script, since it requires `gh auth login` interactively.

### Chezmoi Files to Remove

- `scripts/` (entire directory)

### Dependencies and Blockers

- GPG key generation depends on `gnupg` being available (Phase 1)
- GitHub authentication (`gh auth login`) must happen before GPG key can be added to GitHub
- Consider keeping a minimal `setup.sh` for initial bootstrap (install Nix, run `home-manager switch`)

---

## Phase 7: Cleanup

Remove all remaining Chezmoi files and update bootstrap process.

### What to Remove

- `.chezmoi.yaml.tmpl`
- `.chezmoidata/` (entire directory)
- `.chezmoiignore`
- Any remaining `dot_*` files and directories
- `chezmoi` references from documentation

### What to Update

**`setup.sh`** — Rewrite to:

1. Install Nix (if not present)
2. Enable flakes
3. Run `home-manager switch --flake .`

```bash
#!/bin/bash
set -euo pipefail

# Install Nix
if ! command -v nix &> /dev/null; then
  sh <(curl -L https://nixos.org/nix/install) --daemon
fi

# Enable flakes (if not already enabled)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Apply Home Manager configuration
nix run home-manager -- switch --flake .
```

**`CLAUDE.md`** — Update to reflect pure Home Manager setup:
- Remove Chezmoi references
- Update directory structure
- Update management tools section

### Final Repository Structure

```
dotfiles/
├── flake.nix               # Nix Flake entry point
├── flake.lock              # Flake lock file
├── home.nix                # Home Manager main configuration
├── nvim/                   # Neovim configuration
│   ├── init.lua
│   └── lua/
├── bin/                    # Custom scripts (plain files)
├── claude/                 # Claude Code settings
├── config/
│   └── claude/             # Claude CLI settings
├── setup.sh                # Bootstrap script
├── CLAUDE.md               # Project instructions
└── docs/
    └── plans/              # Planning documents
```

### Dependencies and Blockers

- All previous phases must be completed
- Verify `home-manager switch --flake .` works end-to-end on a clean system
- Test on both native Ubuntu and WSL2

---

## Execution Order and Dependencies

```
Phase 1 (Packages)
    │
    ├──> Phase 2 (Shell)
    │        │
    │        └──> Phase 3 (Git) ──> Phase 6 (Scripts)
    │
    ├──> Phase 4 (Neovim)
    │
    └──> Phase 5 (Other Configs)
                                          │
                                          v
                                    Phase 7 (Cleanup)
```

- **Phase 1** is the foundation; all others depend on it
- **Phases 2-5** can proceed in parallel after Phase 1, but the recommended order minimizes risk
- **Phase 6** depends on Phase 3 (GPG signing config)
- **Phase 7** must be last, after all other phases are verified

## Verification Per Phase

For each phase:

1. Run `home-manager switch --flake .`
2. Open a new shell and verify the migrated configuration works
3. Confirm no regressions in existing functionality
4. Remove the corresponding Chezmoi files
5. Run `chezmoi apply` to confirm Chezmoi no longer manages those files
6. Commit the changes

---

## Progress

- [ ] **Phase 1: Packages** — Migrate mise/aqua/apt tools to `home.packages`
  - [ ] Add packages to `home.nix`
  - [ ] Verify with `home-manager switch --flake .`
  - [ ] Remove `dot_config/mise/`, `dot_config/aquaproj-aqua/`, `dot_default-npm-packages`
- [ ] **Phase 2: Shell (zsh)** — Migrate to `programs.zsh` (blocked by: Phase 1)
  - [ ] Configure `programs.zsh` (history, aliases, plugins, initExtra)
  - [ ] Configure `programs.fzf`, `programs.zoxide`, `programs.direnv`
  - [ ] Verify with `home-manager switch --flake .`
  - [ ] Remove `dot_zshrc`, `dot_zsh.d/`
- [ ] **Phase 3: Git** — Migrate to `programs.git` (blocked by: Phase 2)
  - [ ] Configure `programs.git` (aliases, ignores, extraConfig, signing, includes)
  - [ ] Decide GPG signing key strategy
  - [ ] Verify with `home-manager switch --flake .`
  - [ ] Remove `dot_gitconfig.tmpl`, `dot_config/git/`
- [ ] **Phase 4: Neovim** — Migrate via `xdg.configFile` (blocked by: Phase 1)
  - [ ] Move `dot_config/nvim/` to `nvim/`
  - [ ] Configure `programs.neovim` + `xdg.configFile."nvim"`
  - [ ] Add treesitter build dependencies if needed
  - [ ] Verify with `home-manager switch --flake .`
  - [ ] Remove `dot_config/nvim/`
- [ ] **Phase 5: Other Configs** — Claude CLI, Claude Code, bin scripts (blocked by: Phase 1)
  - [ ] Migrate `dot_config/claude/` to `xdg.configFile`
  - [ ] Migrate `dot_claude/` to `home.file`
  - [ ] Migrate `bin/` scripts (rename to remove `executable_` prefix)
  - [ ] Verify with `home-manager switch --flake .`
  - [ ] Remove `dot_config/claude/`, `dot_claude/`
- [ ] **Phase 6: Scripts** — Migrate or remove Chezmoi scripts (blocked by: Phase 3)
  - [ ] Add GPG key generation as activation script
  - [ ] Remove obsolete scripts (mise, zplug, apt)
  - [ ] Verify with `home-manager switch --flake .`
  - [ ] Remove `scripts/`
- [ ] **Phase 7: Cleanup** — Remove all Chezmoi files (blocked by: Phase 4, 5, 6)
  - [ ] Remove `.chezmoi.yaml.tmpl`, `.chezmoidata/`, `.chezmoiignore`
  - [ ] Remove any remaining `dot_*` files
  - [ ] Rewrite `setup.sh` for Nix-only bootstrap
  - [ ] Update `CLAUDE.md`
  - [ ] End-to-end verification on clean system
