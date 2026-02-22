# Global Instructions

## GitHub

- When creating a pull request, always assign `nownabe` as the assignee

## @nownabe/claude-tools

`@nownabe/claude-tools` provides GitHub-related CLI utilities. Run via `bunx @nownabe/claude-tools <command>`.

Available commands:

- `gh add-sub-issues <parent> <sub>...` — add sub-issues to a parent issue
- `gh get-actions-run <run_id>` — get GitHub Actions workflow run info
- `gh get-release [--tag <tag>] [--jq <expr>]` — get release info (latest by default)
- `gh list-sub-issues <issue_number>` — list sub-issues of an issue
- `gh resolve-tag-sha <owner/repo> <tag>` — resolve a tag to its commit SHA (useful for pinning GitHub Actions)

All commands accept `--repo <owner/repo>` to target a specific repository (defaults to current repo).
