# dotfiles

nownabe's dotfiles repository. Manages user configurations for Ubuntu (x86_64-linux), supporting both native Ubuntu and WSL2.

## Management Tools

Currently migrating incrementally from **Chezmoi** to **Nix Home Manager** (Flake-based standalone).

- **Nix Home Manager**: Managed via `flake.nix` + `home.nix`. New configurations should be added here
- **Chezmoi**: Managed via `dot_*` files. Remove from Chezmoi as each configuration is migrated

### Migration Strategy

Migrate one configuration at a time in the following order:

1. **Packages** — Move tool installations (currently managed by mise/aqua) to `home.packages`
2. **Shell** — Migrate zsh configuration (`dot_zshrc`, `dot_zsh.d/`) to `programs.zsh`
3. **Git** — Migrate git configuration (`dot_gitconfig.tmpl`) to `programs.git`
4. **Neovim** — Migrate Neovim configuration (`dot_config/nvim/`) to `programs.neovim` or `xdg.configFile`
5. **Other configs** — Migrate remaining dotfiles (Claude CLI, stylua, etc.)
6. **Scripts** — Migrate Chezmoi scripts (`scripts/`) to Home Manager activation scripts or remove
7. **Cleanup** — Remove Chezmoi files (`.chezmoi.yaml.tmpl`, `.chezmoidata/`, `dot_*`, `scripts/`)

For each step:
- Add the configuration to `home.nix` (or a new module)
- Verify it works with `home-manager switch --flake .`
- Remove the corresponding Chezmoi files
- Use `programs.*` options when available (e.g., `programs.git`, `programs.zsh`) instead of raw file placement, as they provide type checking and option merging

## Directory Structure

```
dotfiles/
├── flake.nix                   # Nix Flake entry point (dependency management)
├── home.nix                    # Home Manager configuration (user environment)
├── .chezmoi.yaml.tmpl          # Chezmoi configuration template
├── .chezmoidata/               # Chezmoi data (git user info, etc.)
├── bin/                        # Custom scripts
├── dot_config/                 # ~/.config configurations
│   ├── nvim/                   # Neovim (lazy.nvim based)
│   ├── git/                    # Git
│   ├── mise/                   # Mise
│   ├── aquaproj-aqua/          # Aqua
│   └── claude/                 # Claude CLI
├── dot_zsh.d/                  # Zsh modular configurations
├── dot_claude/                 # Claude Code settings
└── scripts/                    # Chezmoi scripts (run_*)
```

## Pull Request Rules

### Branch

- Base branch: `main`

### Title

Use Conventional Commits format:

```
<type>(<scope>): <description>
```

- `type`: `feat`, `fix`, `refactor`, `chore`, `docs`, etc.
- `scope`: target area (`nix`, `nvim`, `git`, `zsh`, `claude`, etc.)
- `description`: English, lowercase start, no trailing period

Examples:
- `feat(nix): add Nix Home Manager configuration`
- `fix(nvim): resolve LSP startup error`
- `refactor(zsh): modularize shell configuration`

### Body

```markdown
## Summary
<bullet points summarizing changes>

## Test plan
<checklist of testing steps>
```

### Labels

Apply the following labels:

- `agent/claude-code` — PR created by Claude Code
- `model/<model-name>` — model used (e.g., `model/claude-opus-4.5`)

### Assignee

- Assign `nownabe`

### Commit Messages

- Same Conventional Commits format as PR titles
- Commits made by Claude Code must include at the end:
  ```
  Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
  ```

### Git Workflow

**Before making changes to an existing PR:**

1. Check PR status: `gh pr view <PR番号> --json state`
2. If `OPEN`: checkout the branch, add new commits (do NOT use `--amend`)
3. If `MERGED`: checkout main, pull, create a NEW branch

**Rules:**

- NEVER use `git commit --amend` for PR branches
- NEVER use `git push --force` unless explicitly requested by user
- ALWAYS check if PR is merged before pushing to a branch
- When PR is already merged, create a new PR from a fresh branch
