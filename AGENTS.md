# dotfiles

nownabe's dotfiles repository. Manages user configurations for Ubuntu (x86_64-linux), supporting both native Ubuntu and WSL2.

## Management Tools

Managed by **Nix Home Manager** (Flake-based standalone) via `flake.nix` + `home.nix`.

Two entrypoints are available in `flake.nix`:
- `wsl` — for WSL2 environments (includes WSL-specific scripts)
- `linux` — for native Linux environments

Apply with the `hms` shell alias (defined in `programs/zsh/default.nix`), which automatically selects the correct entrypoint.

### Adding New Configurations

- Add the configuration to `home.nix` (or a new module under `programs/`)
- Use `programs.*` options when available (e.g., `programs.git`, `programs.zsh`) instead of raw file placement, as they provide type checking and option merging
- Verify it works with `hms`

## Directory Structure

```
dotfiles/
├── flake.nix                   # Nix Flake entry point (wsl / linux configs)
├── home.nix                    # Home Manager configuration (user environment)
├── programs/                   # Modular configurations
│   ├── zsh/                    # Zsh (programs.zsh + config files)
│   ├── git/                    # Git (programs.git + scripts)
│   ├── nvim/                   # Neovim (programs.neovim + config dir)
│   └── claude/                 # Claude Code (settings.json + scripts)
├── setup.sh                    # Bootstrap script (install Nix + apply)
├── scripts/                    # Utility scripts
└── archived/                   # Old Chezmoi files (kept for reference)
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

Write all PR body content in **English**.

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
