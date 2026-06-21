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
