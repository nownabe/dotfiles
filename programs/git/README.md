# Git

Git configuration managed via `programs.git` in `default.nix`, plus global hooks and helper scripts.

## Global Hooks

`core.hooksPath` points at `~/.config/git/hooks`, which means Git ignores every repository's own `.git/hooks/`. The hooks deployed there restore repo-local hooks by chaining to them:

- **`hooks/chain-local`** — installed under each standard hook name (`pre-commit`, `commit-msg`, etc.). Simply forwards to the matching repo-local `.git/hooks/<name>` if it exists and is executable.
- **`hooks/post-checkout`** — chains to the repo-local `post-checkout` first, then runs the worktree-symlink logic below.

## Worktree Symlinks (`.worktree-symlinks`)

When a new linked worktree is created (e.g. `git worktree add`), the `post-checkout` hook symlinks files from the main worktree into the new worktree. This is useful for untracked local files such as `.env` or `.claude/settings.local.json` that every worktree needs.

### Configuration

Create a `.worktree-symlinks` file at the repository root (main worktree). One repo-root-relative path per line; blank lines and `#` comments are allowed:

```
# local files shared across worktrees
.env
.claude/settings.local.json
```

The file can be committed and shared, or kept local (gitignored) — both work.

### Behavior

- Fires only on worktree creation (previous HEAD is the null OID), in a linked worktree of a non-bare repository. Ordinary checkouts, the main worktree, and bare repositories are skipped.
- Creates relative symlinks pointing back to the main worktree (e.g. `.env -> ../../.env`).
- Never clobbers: an existing symlink is left as is (silently); an existing real file/directory is skipped with a warning.
- A missing source in the main worktree is skipped with a warning.
- Absolute paths and paths containing `..` are rejected with a warning, since the config file may be committed by others.

### Tests

```shell
bash programs/git/hooks/post-checkout.test.sh
bash programs/git/hooks/chain-local.test.sh
```

## Scripts

Installed to `~/.local/bin`:

- **`git-wt-helper`** — worktree helper behind the `git wt` workflow. Creates or switches to a worktree for a branch, reuses worktrees whose branches are already merged (including squash merges), and offers fzf selection when run without arguments. Supports both bare repos (`<repo>/wt-xxx/`) and non-bare repos (`<repo>/.worktrees/wt-xxx/`). See `git-wt-helper --help`.
- **`git-clean-squashed`** — deletes local branches whose changes are already merged into the default branch, including squash-merged branches.
