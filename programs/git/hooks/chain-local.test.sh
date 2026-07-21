#!/usr/bin/env bash
#
# Tests for the global chain-local hook dispatcher.
# Run: bash programs/git/hooks/chain-local.test.sh

set -o nounset
set -o pipefail

DISPATCHER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/chain-local"

# Isolate from the user's global/system git config so the real global
# hooksPath never fires, and commits don't sign.
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

# Install the dispatcher as <hooks-path>/<name> and invoke it inside $repo.
# Usage: run_dispatch <repo> <hook-name> [args...]
run_dispatch() {
  local repo=$1 name=$2; shift 2
  local dir; dir=$(mktemp -d)
  ln -s "$DISPATCHER" "$dir/$name"
  ( cd "$repo" && "$dir/$name" "$@" )
  local rc=$?
  rm -rf "$dir"
  return $rc
}

test_chains_local_pre_commit() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  {
    printf '#!/usr/bin/env bash\n'
    printf 'touch "%s/.pre-commit-ran"\n' "$repo"
  } > "$repo/.git/hooks/pre-commit"
  chmod +x "$repo/.git/hooks/pre-commit"

  run_dispatch "$repo" pre-commit

  if [[ -f "$repo/.pre-commit-ran" ]]; then ok; else fail "local pre-commit was not chained"; fi

  rm -rf "$repo"
}

test_passes_arguments_through() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  {
    printf '#!/usr/bin/env bash\n'
    # $1 is the generated hook's own positional arg, not this script's.
    # shellcheck disable=SC2016
    printf 'printf "%%s" "$1" > "%s/.args"\n' "$repo"
  } > "$repo/.git/hooks/commit-msg"
  chmod +x "$repo/.git/hooks/commit-msg"

  run_dispatch "$repo" commit-msg .git/COMMIT_EDITMSG

  if [[ "$(cat "$repo/.args" 2>/dev/null)" == ".git/COMMIT_EDITMSG" ]]; then
    ok
  else
    fail "argument not forwarded: $(cat "$repo/.args" 2>/dev/null)"
  fi

  rm -rf "$repo"
}

test_missing_local_hook_is_noop() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"   # no repo-local pre-push hook

  if run_dispatch "$repo" pre-push; then ok; else fail "dispatcher failed when no local hook exists"; fi

  rm -rf "$repo"
}

test_non_executable_local_hook_is_skipped() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  printf '#!/usr/bin/env bash\nexit 1\n' > "$repo/.git/hooks/pre-commit"  # not chmod +x

  if run_dispatch "$repo" pre-commit; then ok; else fail "non-executable local hook was run"; fi

  rm -rf "$repo"
}

test_propagates_exit_code() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  printf '#!/usr/bin/env bash\nexit 7\n' > "$repo/.git/hooks/pre-commit"
  chmod +x "$repo/.git/hooks/pre-commit"

  run_dispatch "$repo" pre-commit
  if [[ $? -eq 7 ]]; then ok; else fail "exit code not propagated"; fi

  rm -rf "$repo"
}

test_chains_from_linked_worktree() {
  local repo; repo=$(mktemp -d)
  make_repo "$repo"
  {
    printf '#!/usr/bin/env bash\n'
    printf 'touch "%s/.pre-commit-ran"\n' "$repo"
  } > "$repo/.git/hooks/pre-commit"
  chmod +x "$repo/.git/hooks/pre-commit"
  git -C "$repo" worktree add -q -b feat "$repo/.worktrees/wt-001" >/dev/null 2>&1

  run_dispatch "$repo/.worktrees/wt-001" pre-commit

  # The linked worktree shares the common dir's hooks, so the hook must fire.
  if [[ -f "$repo/.pre-commit-ran" ]]; then ok; else fail "hook not chained from linked worktree"; fi

  rm -rf "$repo"
}

# --- runner ---
for t in $(declare -F | awk '{print $3}' | grep '^test_'); do
  printf '# %s\n' "$t"
  "$t"
done
printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]]
