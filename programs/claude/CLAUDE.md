# Global Instructions

## GitHub

- When creating a pull request, always assign `nownabe` as the assignee

## @nownabe/claude-tools

`@nownabe/claude-tools` provides GitHub-related CLI utilities. Run via `bunx @nownabe/claude-tools <command>`.

Available commands:

- `gh add-sub-issues <parent_issue_number> <sub_issue_number>...` — add sub-issues to a parent issue
- `gh get-actions-run <run_id>` — get GitHub Actions workflow run info
- `gh get-job-logs <job_id> [--no-strip-timestamps]` — get logs for a specific job
- `gh get-release [--tag <tag>]` — get release info (latest by default)
- `gh get-repo-content <path> [--ref <ref>] [--raw]` — get file content from a GitHub repository
- `gh list-run-jobs <run_id>` — list jobs for a workflow run
- `gh list-sub-issues <issue_number>` — list sub-issues of an issue
- `gh resolve-tag-sha <owner/repo> <tag>` — resolve a tag to its commit SHA (useful for pinning GitHub Actions)

All commands accept `--repo <owner/repo>` to target a specific repository (defaults to current repo).
