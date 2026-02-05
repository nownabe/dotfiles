# Bare Repo + Worktree Migration Plan

Migrate `git-wt-helper` to use bare clones (`ghq get --bare`) with all branches managed as `wt-xxx` worktrees.

## Current State

- `ghq get` creates a normal (non-bare) clone
- The cloned repo root is the main worktree (default branch)
- Feature branches are worktrees under `<repo>/.worktrees/wt-001, wt-002, ...`
- `git wt -b` returns to the main worktree (repo root)

```
~/src/github.com/user/repo/              ← main worktree (main branch)
~/src/github.com/user/repo/.worktrees/
  wt-001/                                ← feature-a
  wt-002/                                ← feature-b
```

## Target State

- `ghq get --bare` creates a bare clone
- All branches (including default) are `wt-xxx` worktrees inside the bare repo root
- No branch gets special treatment; all are equal
- `.worktrees` directory is eliminated

```
~/src/github.com/user/repo/              ← bare repo (HEAD, objects/, refs/, ...)
  wt-001/                                ← main
  wt-002/                                ← feature-a
  wt-003/                                ← feature-b
```

## Design Decisions

| Topic | Decision |
|---|---|
| Worktree location | Directly under bare repo root as `wt-xxx` |
| Default branch | No special treatment; just another `wt-xxx` |
| `git wt -b` | Goes to bare repo root |
| Non-bare repo support | Keep backward compatibility (detect bare vs non-bare) |
| fzf display | `wt-xxx  branch-name` (already implemented in PR #60) |

---

## Phase 1: Detect Bare Repo

Add bare repo detection to `git-wt-helper` and branch behavior accordingly.

### Changes

**New helper function:**

```bash
is_bare_repo() {
  [[ $(git rev-parse --is-bare-repository 2>/dev/null) == true ]]
}
```

**Get repo root (bare repo aware):**

```bash
get_repo_root() {
  if is_bare_repo; then
    git rev-parse --git-dir
  else
    get_main_worktree
  fi
}
```

**Entry point guard (line 252):**

Currently: `git rev-parse --is-inside-work-tree` — fails in bare repos.
Change to: accept bare repos as well.

```bash
git rev-parse --is-inside-work-tree &>/dev/null ||
  is_bare_repo ||
  die "Not in a git repository"
```

### Files Modified

- `programs/git/scripts/git-wt-helper`

---

## Phase 2: Worktree Directory Logic

Make `get_worktrees_dir` bare-aware. In bare repos, worktrees go directly in the repo root (no `.worktrees` subdirectory).

### Changes

**`get_worktrees_dir()`:**

```bash
get_worktrees_dir() {
  if is_bare_repo; then
    git rev-parse --git-dir
  else
    local main_worktree
    main_worktree=$(get_main_worktree)
    echo "$main_worktree/$WORKTREES_DIR"
  fi
}
```

**`list_worktrees()`:**

For bare repos, the first entry in `git worktree list --porcelain` is the bare repo itself (marked with `bare` instead of `branch`). It must be excluded.

```bash
list_worktrees() {
  git worktree list --porcelain | awk '
    /^worktree / { path = substr($0, 10) }
    /^branch /   { branch = substr($0, 8); sub("refs/heads/", "", branch) }
    /^bare$/     { is_bare = 1 }
    /^$/ {
      if (!is_bare && path != "" && branch != "") {
        print path ":" branch
      }
      path = ""; branch = ""; is_bare = 0
    }
    END {
      if (!is_bare && path != "" && branch != "") {
        print path ":" branch
      }
    }
  '
}
```

Note: For non-bare repos, the main worktree exclusion logic (`path != main`) is no longer needed if we adopt the bare model. However, for backward compatibility with non-bare repos, we should still exclude the main worktree. Refine:

```bash
list_worktrees() {
  local main_worktree=""
  if ! is_bare_repo; then
    main_worktree=$(get_main_worktree)
  fi

  git worktree list --porcelain | awk -v main="$main_worktree" '
    /^worktree / { path = substr($0, 10) }
    /^branch /   { branch = substr($0, 8); sub("refs/heads/", "", branch) }
    /^bare$/     { is_bare = 1 }
    /^$/ {
      if (!is_bare && path != main && path != "" && branch != "") {
        print path ":" branch
      }
      path = ""; branch = ""; is_bare = 0
    }
    END {
      if (!is_bare && path != main && path != "" && branch != "") {
        print path ":" branch
      }
    }
  '
}
```

### Files Modified

- `programs/git/scripts/git-wt-helper`

---

## Phase 3: fzf Selection for Bare Repos

Update `select_with_fzf` to handle bare repos. In bare repos there is no "main worktree" entry — all entries come from `list_worktrees`.

### Changes

**`select_with_fzf()`:**

```bash
select_with_fzf() {
  local fzf_out query selected

  fzf_out=$(
    {
      if ! is_bare_repo; then
        local main_worktree default_branch
        main_worktree=$(get_main_worktree)
        default_branch=$(get_default_branch)
        printf '%s\t%s  %s\n' "$main_worktree" "(main)" "$default_branch"
      fi
      list_worktrees | while IFS=: read -r path branch; do
        printf '%s\t%s  %s\n' "$path" "$(basename "$path")" "$branch"
      done
    } | fzf --prompt='worktree> ' \
        --with-nth=2 \
        --delimiter=$'\t' \
        --preview='cd {1} && git log --oneline -10' \
        --print-query
  ) || true

  query=$(echo "$fzf_out" | sed -n '1p')
  selected=$(echo "$fzf_out" | sed -n '2p')

  if [[ -n $selected ]]; then
    echo "$selected" | cut -d$'\t' -f1
  elif [[ -n $query ]]; then
    exec "$0" "$query"
  fi
}
```

### Files Modified

- `programs/git/scripts/git-wt-helper`

---

## Phase 4: Shell Wrapper (`git wt -b`)

Update the `gitwt` function in `programs/zsh/config/git.zsh` so that `git wt -b` works for bare repos.

### Current Behavior

```bash
# git wt -b → cd to main worktree via git-common-dir
git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
cd "$git_common_dir/.."
```

This works for non-bare repos where `.git` is a file pointing to the common dir, and `..` is the main worktree.

### Bare Repo Behavior

In a bare repo worktree, `git rev-parse --git-common-dir` returns the bare repo path itself. `cd "$git_common_dir/.."` would go one level too high.

Need to detect bare repos:

```bash
if [[ $1 == "-b" ]]; then
  shift
  local git_common_dir
  if git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null); then
    if [[ $(git rev-parse --is-bare-repository 2>/dev/null) == true ]]; then
      cd "$git_common_dir"
    else
      cd "$git_common_dir/.."
    fi
  else
    echo "Not in a git repository" >&2
    return 1
  fi
  return
fi
```

### Files Modified

- `programs/zsh/config/git.zsh`

---

## Phase 5: ghq Workflow

Set up an alias or wrapper for cloning with bare + initial worktree creation.

### Option A: Manual two-step

```bash
ghq get --bare user/repo
cd ~/src/github.com/user/repo
git wt main   # creates wt-001 for main branch
```

### Option B: Shell function (recommended)

Add a `ghq-bare` function or modify the existing `fzf-ghq` flow:

```bash
ghq-bare() {
  ghq get --bare "$@"
  local repo_path
  repo_path=$(ghq list --full-path --exact "$1" 2>/dev/null) || return
  cd "$repo_path"
  git-wt-helper "$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')"
}
```

Or integrate into `git wt` itself — when run inside a bare repo with no worktrees, automatically create one for the default branch.

### Design Choice

To be decided: whether to automate initial worktree creation or keep it manual. Automation is convenient but adds complexity.

### Files Modified

- `programs/zsh/config/git.zsh` (if adding shell function)

---

## Phase 6: Migration of Existing Repos (Optional)

Existing normal clones continue to work (backward compatibility maintained in all phases). Migration to bare is optional and per-repo:

```bash
# No automated migration planned.
# New repos: ghq get --bare
# Existing repos: keep as-is or re-clone manually
```

---

## Execution Order

```
Phase 1 (Bare detection)
  └──> Phase 2 (Worktree dir logic)
         └──> Phase 3 (fzf selection)
                └──> Phase 4 (Shell wrapper)
                       └──> Phase 5 (ghq workflow)
                              └──> Phase 6 (Migration, optional)
```

All phases depend on the previous one. Phase 6 is optional.

---

## Progress

- [ ] **Phase 1**: Bare repo detection
- [ ] **Phase 2**: Worktree directory logic (bare-aware)
- [ ] **Phase 3**: fzf selection for bare repos
- [ ] **Phase 4**: Shell wrapper `git wt -b` for bare repos
- [ ] **Phase 5**: ghq bare clone workflow
- [ ] **Phase 6**: Migration of existing repos (optional)
