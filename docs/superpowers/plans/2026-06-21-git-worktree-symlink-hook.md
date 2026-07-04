# git worktree symlink hook Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Globally configured git `post-checkout` hook that, on worktree creation, symlinks files listed in per-repo `nownabe.worktreeSymlink` config from the main worktree into the new worktree, and chains to any repo-local `post-checkout` hook.

**Architecture:** A single bash hook script deployed by Nix Home Manager to `~/.config/git/hooks/post-checkout`, with `core.hooksPath` pointed at that directory. The script first chains to the repository-local hook (which `core.hooksPath` would otherwise disable), then — only on worktree creation (`$1` == null OID) and only inside a non-bare linked worktree — iterates `nownabe.worktreeSymlink` and creates relative symlinks back to the main worktree.

**Tech Stack:** Bash, git (2.54), Nix Home Manager (`programs.git`, `home.file`). Tests are a self-contained bash harness using temporary git repos.

## Global Constraints

- Target OS: Ubuntu x86_64-linux (native + WSL2). GNU coreutils available (`realpath -m --relative-to`).
- Config key: `nownabe.worktreeSymlink` (multi-valued), values are repo-root-relative paths.
- symlink link target form: **relative** path.
- Trigger: worktree creation only — `$1` (previous HEAD) equals the null OID `0000000000000000000000000000000000000000`.
- bare repositories: symlink processing is skipped (chaining still runs).
- Output goes to **stderr**, prefixed `worktree-symlink:`.
- Never write/read/search files with the Bash tool in this session — use Write/Edit/Read. (Hook and test _scripts_ may of course contain shell commands.)
- `hms` must be run from the user's interactive shell, not via the Bash tool.
- Commit messages: Conventional Commits, scope `git`. No `Co-Authored-By`, no "Generated with" lines.

---

## File Structure

- `programs/git/hooks/post-checkout` — the global hook script (deployed, executable).
- `programs/git/hooks/post-checkout.test.sh` — bash test harness (not deployed).
- `programs/git/default.nix` — add `core.hooksPath` setting and `home.file` entry.

---

### Task 1: Test harness + happy-path symlink creation

**Files:**

- Create: `programs/git/hooks/post-checkout`
- Create: `programs/git/hooks/post-checkout.test.sh`

**Interfaces:**

- Produces: hook script invoked as `post-checkout <prev_head> <new_head> <flag>`, run with CWD inside a worktree. On worktree creation it reads `git config --get-all nownabe.worktreeSymlink` and creates relative symlinks in the current worktree pointing to the same relative path in the main worktree.
- Test harness exposes shell helpers `make_repo`, `add_worktree`, `run_hook_create`, `ok`, `fail`, and auto-runs every `test_*` function.

- [ ] **Step 1: Write the failing test (harness + happy path)**

Create `programs/git/hooks/post-checkout.test.sh`:

```bash
#!/usr/bin/env bash
#
# Tests for the global post-checkout worktree-symlink hook.
# Run: bash programs/git/hooks/post-checkout.test.sh

set -o nounset
set -o pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/post-checkout"
NULL_OID="0000000000000000000000000000000000000000"
SOME_OID="1111111111111111111111111111111111111111"

# Isolate from the user's global/system git config so the real global
# hooksPath never fires during `git worktree add`, and commits don't sign.
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_SYSTEM=/dev/null
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

PASS=0
FAIL=0
ok()   { PASS=$((PASS + 1)); }
fail() { printf '  FAIL: %s\n' "$1"; FAIL=$((FAIL + 1)); }

# Create a non-bare repo with one commit at $1.
make_repo() {
  git init -q "$1"
  git -C "$1" commit -q --allow-empty -m init
}

# Add a linked worktree at <repo>/.worktrees/wt-001 on a new branch.
add_worktree() {
  git -C "$1" worktree add -q -b feat "$1/.worktrees/wt-001" >/dev/null 2>&1
}

# Run the hook inside $1 as a worktree-creation checkout; stderr -> ${2:-/dev/null}.
run_hook_create() {
  ( cd "$1" && "$HOOK" "$NULL_OID" "$SOME_OID" 1 ) 2>"${2:-/dev/null}"
}

test_creates_relative_symlink() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  git -C "$repo" config --add nownabe.worktreeSymlink .env
  printf 'SECRET=1\n' > "$repo/.env"
  add_worktree "$repo"

  local out; out=$(mktemp)
  run_hook_create "$repo/.worktrees/wt-001" "$out"

  local wt="$repo/.worktrees/wt-001"
  if [[ -L "$wt/.env" ]]; then ok; else fail "symlink not created"; fi
  if [[ "$(readlink "$wt/.env")" == "../../.env" ]]; then
    ok
  else
    fail "wrong link target: $(readlink "$wt/.env" 2>/dev/null)"
  fi
  if grep -q 'created .env' "$out"; then ok; else fail "no success message: $(cat "$out")"; fi

  rm -rf "$repo" "$out"
}

# --- runner ---
for t in $(declare -F | awk '{print $3}' | grep '^test_'); do
  printf '# %s\n' "$t"
  "$t"
done
printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]]
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash programs/git/hooks/post-checkout.test.sh`
Expected: FAIL — the hook file does not exist yet, so symlink/message assertions fail (e.g. "symlink not created").

- [ ] **Step 3: Write the minimal hook implementation**

Create `programs/git/hooks/post-checkout`:

```bash
#!/usr/bin/env bash
#
# Global post-checkout hook.
#
# On worktree creation, symlinks files listed in the per-repo multi-valued
# config `nownabe.worktreeSymlink` from the main worktree into the new
# worktree (relative links). Only fires for non-bare repos, in a linked
# worktree, when the previous HEAD is the null OID.

set -o nounset
set -o pipefail

NULL_OID="0000000000000000000000000000000000000000"
PREFIX="worktree-symlink"

create_symlinks() {
  local main_worktree=$1 current_worktree=$2
  local rel source target target_dir link_target

  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    source="$main_worktree/$rel"
    target="$current_worktree/$rel"

    # Already a symlink: do nothing, silently.
    [[ -L "$target" ]] && continue

    # A real file/dir already exists: don't clobber.
    if [[ -e "$target" ]]; then
      printf '%s: warning: %s already exists and is not a symlink, skipping\n' \
        "$PREFIX" "$rel" >&2
      continue
    fi

    # Configured source is missing.
    if [[ ! -e "$source" ]]; then
      printf '%s: warning: source not found: %s\n' "$PREFIX" "$rel" >&2
      continue
    fi

    target_dir=$(dirname "$target")
    if ! mkdir -p "$target_dir"; then
      printf '%s: error: failed to create directory for %s\n' "$PREFIX" "$rel" >&2
      continue
    fi

    link_target=$(realpath -m --relative-to="$target_dir" "$source")
    if ln -s "$link_target" "$target"; then
      printf '%s: created %s -> %s\n' "$PREFIX" "$rel" "$link_target" >&2
    else
      printf '%s: error: failed to create symlink for %s\n' "$PREFIX" "$rel" >&2
    fi
  done < <(git config --get-all nownabe.worktreeSymlink 2>/dev/null)
}

main() {
  local prev_head="${1-}"

  # Only react to worktree creation (previous HEAD is the null OID).
  [[ "$prev_head" == "$NULL_OID" ]] || return 0

  local common_dir
  common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return 0
  common_dir=$(cd "$common_dir" 2>/dev/null && pwd) || return 0

  # Skip bare repositories (common dir is not named ".git").
  [[ "$(basename "$common_dir")" == ".git" ]] || return 0

  local main_worktree current_worktree
  main_worktree=$(dirname "$common_dir")
  current_worktree=$(git rev-parse --show-toplevel 2>/dev/null) || return 0

  # Skip the main worktree itself (source == target).
  [[ "$current_worktree" == "$main_worktree" ]] && return 0

  create_symlinks "$main_worktree" "$current_worktree"
}

main "$@"
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bash programs/git/hooks/post-checkout.test.sh`
Expected: PASS — `3 passed, 0 failed` (the single test makes three assertions). Exit status 0.

- [ ] **Step 5: Commit**

```bash
git add programs/git/hooks/post-checkout programs/git/hooks/post-checkout.test.sh
git commit -m "feat(git): add worktree symlink post-checkout hook"
```

---

### Task 2: State branches — idempotent, non-symlink clobber, missing source

**Files:**

- Modify: `programs/git/hooks/post-checkout.test.sh` (add three `test_*` functions)
- (No hook change expected — these branches were implemented in Task 1; tests lock the behavior in.)

**Interfaces:**

- Consumes: `make_repo`, `add_worktree`, `run_hook_create`, `ok`, `fail` from Task 1.

- [ ] **Step 1: Write the failing tests**

Add these three functions to `programs/git/hooks/post-checkout.test.sh`, just before the `# --- runner ---` line:

```bash
test_existing_symlink_is_silent() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  git -C "$repo" config --add nownabe.worktreeSymlink .env
  printf 'SECRET=1\n' > "$repo/.env"
  add_worktree "$repo"
  local wt="$repo/.worktrees/wt-001"

  # First run creates the symlink.
  run_hook_create "$wt"
  # Second run must be silent and leave the symlink intact.
  local out; out=$(mktemp)
  run_hook_create "$wt" "$out"

  if [[ -L "$wt/.env" ]]; then ok; else fail "symlink disappeared on second run"; fi
  if [[ -s "$out" ]]; then fail "second run produced output: $(cat "$out")"; else ok; fi

  rm -rf "$repo" "$out"
}

test_non_symlink_is_not_clobbered() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  git -C "$repo" config --add nownabe.worktreeSymlink .env
  printf 'SECRET=1\n' > "$repo/.env"
  add_worktree "$repo"
  local wt="$repo/.worktrees/wt-001"
  printf 'LOCAL=1\n' > "$wt/.env"   # pre-existing real file

  local out; out=$(mktemp)
  run_hook_create "$wt" "$out"

  if [[ -L "$wt/.env" ]]; then fail "real file was replaced by symlink"; else ok; fi
  if [[ "$(cat "$wt/.env")" == "LOCAL=1" ]]; then ok; else fail "real file content changed"; fi
  if grep -q 'warning' "$out"; then ok; else fail "no warning emitted: $(cat "$out")"; fi

  rm -rf "$repo" "$out"
}

test_missing_source_warns() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  git -C "$repo" config --add nownabe.worktreeSymlink .env   # no .env created
  add_worktree "$repo"
  local wt="$repo/.worktrees/wt-001"

  local out; out=$(mktemp)
  run_hook_create "$wt" "$out"

  if [[ -e "$wt/.env" || -L "$wt/.env" ]]; then fail "symlink/file created for missing source"; else ok; fi
  if grep -q 'source not found: .env' "$out"; then ok; else fail "no source-not-found warning: $(cat "$out")"; fi

  rm -rf "$repo" "$out"
}
```

- [ ] **Step 2: Run the tests to verify they pass**

Run: `bash programs/git/hooks/post-checkout.test.sh`
Expected: PASS — all assertions green (`... passed, 0 failed`). If any fail, fix the corresponding branch in `programs/git/hooks/post-checkout` (`create_symlinks`) so the order is: existing symlink → silent; existing non-symlink → warning; missing source → warning.

- [ ] **Step 3: Commit**

```bash
git add programs/git/hooks/post-checkout.test.sh programs/git/hooks/post-checkout
git commit -m "test(git): cover symlink idempotency, clobber, missing source"
```

---

### Task 3: Guards — non-creation checkout, main worktree, bare repo

**Files:**

- Modify: `programs/git/hooks/post-checkout.test.sh` (add three `test_*` functions and a `make_bare_with_worktree` helper)

**Interfaces:**

- Consumes: `make_repo`, `add_worktree`, `run_hook_create`, `HOOK`, `NULL_OID`, `SOME_OID`, `ok`, `fail`.

- [ ] **Step 1: Write the failing tests**

Add this helper near the other helpers (after `add_worktree`) in `programs/git/hooks/post-checkout.test.sh`:

```bash
# Create a bare repo at <base>/repo.git with a worktree at <base>/repo.git/wt-001.
# Echoes the worktree path.
make_bare_with_worktree() {
  local base=$1
  git init -q "$base/seed"
  git -C "$base/seed" commit -q --allow-empty -m init
  git clone -q --bare "$base/seed" "$base/repo.git" >/dev/null 2>&1
  git -C "$base/repo.git" worktree add -q -b feat "$base/repo.git/wt-001" >/dev/null 2>&1
  printf '%s\n' "$base/repo.git/wt-001"
}
```

Add these three functions just before the `# --- runner ---` line:

```bash
test_non_creation_checkout_is_skipped() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  git -C "$repo" config --add nownabe.worktreeSymlink .env
  printf 'SECRET=1\n' > "$repo/.env"
  add_worktree "$repo"
  local wt="$repo/.worktrees/wt-001"

  # Non-null previous HEAD == ordinary branch switch, not worktree creation.
  local out; out=$(mktemp)
  ( cd "$wt" && "$HOOK" "$SOME_OID" "$SOME_OID" 1 ) 2>"$out"

  if [[ -L "$wt/.env" ]]; then fail "symlink created on non-creation checkout"; else ok; fi
  if [[ -s "$out" ]]; then fail "unexpected output: $(cat "$out")"; else ok; fi

  rm -rf "$repo" "$out"
}

test_main_worktree_is_skipped() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  git -C "$repo" config --add nownabe.worktreeSymlink .env
  printf 'SECRET=1\n' > "$repo/.env"

  # Run inside the MAIN worktree with a creation-style prev HEAD.
  local out; out=$(mktemp)
  run_hook_create "$repo" "$out"

  if [[ -L "$repo/.env" ]]; then fail ".env in main worktree was replaced"; else ok; fi
  if [[ -s "$out" ]]; then fail "main worktree produced output: $(cat "$out")"; else ok; fi

  rm -rf "$repo" "$out"
}

test_bare_repo_is_skipped() {
  local base; base=$(mktemp -d)
  local wt; wt=$(make_bare_with_worktree "$base")
  git -C "$base/repo.git" config --add nownabe.worktreeSymlink .env

  local out; out=$(mktemp)
  run_hook_create "$wt" "$out"

  if [[ -e "$wt/.env" || -L "$wt/.env" ]]; then fail "created link in bare worktree"; else ok; fi
  if [[ -s "$out" ]]; then fail "bare repo produced output: $(cat "$out")"; else ok; fi

  rm -rf "$base" "$out"
}
```

- [ ] **Step 2: Run the tests to verify they pass**

Run: `bash programs/git/hooks/post-checkout.test.sh`
Expected: PASS — all assertions green. These guards (`prev_head` null check, `current_worktree == main_worktree`, bare `basename != .git`) were implemented in Task 1's `main`. If any fail, fix `main` accordingly.

- [ ] **Step 3: Commit**

```bash
git add programs/git/hooks/post-checkout.test.sh programs/git/hooks/post-checkout
git commit -m "test(git): cover skip guards for checkout, main worktree, bare"
```

---

### Task 4: Chain to repository-local post-checkout hook

**Files:**

- Modify: `programs/git/hooks/post-checkout` (add `chain_local_hook`, call it first in `main`)
- Modify: `programs/git/hooks/post-checkout.test.sh` (add one `test_*` function)

**Interfaces:**

- Produces: `chain_local_hook "$@"` runs `<git-common-dir>/hooks/post-checkout` with the same arguments when that file is executable and is not this script itself.

- [ ] **Step 1: Write the failing test**

Add this function just before the `# --- runner ---` line in `programs/git/hooks/post-checkout.test.sh`:

```bash
test_chains_local_hook() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  mkdir -p "$repo/.git/hooks"
  {
    printf '#!/usr/bin/env bash\n'
    printf 'touch "%s/.local-hook-ran"\n' "$repo"
  } > "$repo/.git/hooks/post-checkout"
  chmod +x "$repo/.git/hooks/post-checkout"

  add_worktree "$repo"
  # add_worktree itself fired the local hook; clear the marker first.
  rm -f "$repo/.local-hook-ran"

  run_hook_create "$repo/.worktrees/wt-001"

  if [[ -f "$repo/.local-hook-ran" ]]; then ok; else fail "local hook was not chained"; fi

  rm -rf "$repo"
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash programs/git/hooks/post-checkout.test.sh`
Expected: FAIL — `local hook was not chained` (the hook does not chain yet).

- [ ] **Step 3: Add chaining to the hook**

In `programs/git/hooks/post-checkout`, add the `chain_local_hook` function above `main` (after the `create_symlinks` function):

```bash
chain_local_hook() {
  local common_dir local_hook
  common_dir=$(git rev-parse --git-common-dir 2>/dev/null) || return 0
  local_hook="$common_dir/hooks/post-checkout"

  [[ -x "$local_hook" ]] || return 0
  # Don't recurse into ourselves if hooksPath ever points at .git/hooks.
  [[ "$(realpath "$local_hook")" == "$(realpath "${BASH_SOURCE[0]}")" ]] && return 0

  "$local_hook" "$@"
}
```

Then make it the first action in `main` — change the start of `main` from:

```bash
main() {
  local prev_head="${1-}"

  # Only react to worktree creation (previous HEAD is the null OID).
```

to:

```bash
main() {
  local prev_head="${1-}"

  chain_local_hook "$@"

  # Only react to worktree creation (previous HEAD is the null OID).
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bash programs/git/hooks/post-checkout.test.sh`
Expected: PASS — `local hook was not chained` is gone; all assertions green.

- [ ] **Step 5: Commit**

```bash
git add programs/git/hooks/post-checkout programs/git/hooks/post-checkout.test.sh
git commit -m "feat(git): chain worktree symlink hook to local post-checkout"
```

---

### Task 5: Wire up Nix (core.hooksPath + deploy hook) and verify end-to-end

**Files:**

- Modify: `programs/git/default.nix`

**Interfaces:**

- Consumes: the function arg `config` (already in `{ config, lib, pkgs, ... }:`) for `config.home.homeDirectory`.

- [ ] **Step 1: Add `core.hooksPath` setting**

In `programs/git/default.nix`, inside `programs.git.settings`, add `hooksPath` to the existing `core` settings. Change:

```nix
      core.editor = "nvim";
```

to:

```nix
      core.editor = "nvim";
      core.hooksPath = "${config.home.homeDirectory}/.config/git/hooks";
```

- [ ] **Step 2: Deploy the hook via `home.file`**

In `programs/git/default.nix`, inside the `home.file = { ... };` block, add an entry alongside the existing `.local/bin/...` entries:

```nix
    ".config/git/hooks/post-checkout" = {
      source = ./hooks/post-checkout;
      executable = true;
    };
```

- [ ] **Step 3: Validate the flake evaluates**

Run: `nix flake check --no-build 2>&1 | tail -20` (or `nix eval .#homeConfigurations 2>/dev/null` if `flake check` is slow).
Expected: no evaluation errors referencing `programs/git/default.nix`. (If `nix` is unavailable in this context, skip and rely on Step 4.)

- [ ] **Step 4: Apply with Home Manager**

Ask the user to run `hms` in their interactive shell (it cannot be run via the Bash tool — see project memory).
Expected: switch completes without error.

- [ ] **Step 5: Verify deployment**

Run:

```bash
git config --global core.hooksPath
readlink -f ~/.config/git/hooks/post-checkout
test -x ~/.config/git/hooks/post-checkout && echo "executable" || echo "NOT executable"
```

Expected:

- `core.hooksPath` prints `/home/<user>/.config/git/hooks`
- the hook path resolves into the Nix store
- prints `executable`

- [ ] **Step 6: End-to-end smoke test in a scratch repo**

Run:

```bash
tmp=$(mktemp -d)
git init -q "$tmp"
git -C "$tmp" commit -q --allow-empty -m init
git -C "$tmp" config --add nownabe.worktreeSymlink .env
printf 'SECRET=1\n' > "$tmp/.env"
git -C "$tmp" worktree add -b feat "$tmp/.worktrees/wt-001" 2>&1
ls -l "$tmp/.worktrees/wt-001/.env"
rm -rf "$tmp"
```

Expected: `worktree-symlink: created .env -> ../../.env` on stderr, and `.env` in the new worktree is a symlink to `../../.env`.

- [ ] **Step 7: Commit**

```bash
git add programs/git/default.nix
git commit -m "feat(git): enable global worktree symlink hook via hooksPath"
```

---

## Notes for the implementer

- The hook deliberately does **not** use `set -o errexit`: each config entry is handled independently and a failure on one must not abort the rest.
- `realpath -m --relative-to` computes the relative link target without requiring the parent dirs to pre-exist.
- The test harness sets `GIT_CONFIG_GLOBAL=/dev/null` so the real global `core.hooksPath` does not auto-fire during `git worktree add`; this keeps tests deterministic and lets them assert on the hook invoked manually.
- After Task 5, the original `update-claude-settings` branch still has a stashed `flake.lock` change (`git stash list`) — unrelated to this feature.
