# Sourced by the global commit-msg and pre-commit hooks.
#
# Two machine-local files under $XDG_CONFIG_HOME/git, one extended regex per
# line, `#` comments and blank lines ignored, matched case-insensitively:
#
#   private-patterns  what must never reach a public place
#   private-remotes   origin URLs of private repositories, where the
#                     patterns are not enforced
#
# Both stay outside every repository on purpose: what they name is the very
# thing worth keeping out of a public one. The Claude Code hooks read the
# same files (programs/claude/hooks/private-patterns.ts).

PRIVATE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/git"
PRIVATE_PATTERNS_FILE="$PRIVATE_CONFIG_DIR/private-patterns"
PRIVATE_REMOTES_FILE="$PRIVATE_CONFIG_DIR/private-remotes"

# Print the active lines of a pattern file; fail when it is missing or has
# none.
private_active_lines() {
  local file=$1 lines
  [[ -r "$file" ]] || return 1
  lines=$(grep -vE '^[[:space:]]*(#|$)' -- "$file") || return 1
  [[ -n "$lines" ]] || return 1
  printf '%s\n' "$lines"
}

# True when the current repository's origin matches a private remote.
private_repo() {
  local remotes origin
  remotes=$(private_active_lines "$PRIVATE_REMOTES_FILE") || return 1
  origin=$(git remote get-url origin 2>/dev/null) || return 1
  printf '%s\n' "$origin" | grep -qiE -f <(printf '%s\n' "$remotes")
}

# Print the patterns to enforce in the current repository; fail when there
# are none, or when the repository is private.
private_patterns() {
  private_repo && return 1
  private_active_lines "$PRIVATE_PATTERNS_FILE"
}
