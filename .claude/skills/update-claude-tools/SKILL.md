---
name: update-claude-tools
description: >
  Update @nownabe/claude-tools and @nownabe/claude-hooks documentation in the dotfiles repository
  to match the latest commands and hooks from the source repository. Use when the user asks to
  update, sync, or refresh claude-tools or claude-hooks documentation (e.g., "update claude-tools",
  "sync claude-tools docs", "@nownabe/claude-tools を最新化して").
---

# Update Claude Tools

Update `programs/claude/CLAUDE.md` in this repo to reflect the latest commands and hooks from the
`nownabe/claude` source repository. This file is deployed as `~/.claude/CLAUDE.md` via Home Manager.

## Workflow

### 1. Read source

Fetch `README.md` from GitHub using `bunx @nownabe/claude-tools gh get-repo-content README.md --repo nownabe/claude`.

It has:

- **Tools** table — command names and descriptions for `@nownabe/claude-tools`
- **Hooks** table — hook names and descriptions for `@nownabe/claude-hooks`

### 2. Read command docs

For each command in the Tools table, fetch its doc file from GitHub using
`bunx @nownabe/claude-tools gh get-repo-content docs/claude-tools/gh/<command>.md --repo nownabe/claude`.

Extract the usage line from the `## Usage` code block. For example:

```
claude-tools gh get-job-logs <job_id> [--repo <owner/repo>] [--no-strip-timestamps]
```

Transform it for CLAUDE.md:

- Strip the `claude-tools` prefix (keep `gh <command> ...`)
- Remove `[--repo <owner/repo>]` (documented separately as a shared option)
- Combine with the description from the README table

Result: `` `gh get-job-logs <job_id> [--no-strip-timestamps]` — get logs for a specific job ``

### 3. Update CLAUDE.md

Update the `## @nownabe/claude-tools` section in `programs/claude/CLAUDE.md`, preserving this format:

```markdown
## @nownabe/claude-tools

`@nownabe/claude-tools` provides GitHub-related CLI utilities. Run via `bunx @nownabe/claude-tools <command>`.

Available commands:

- `gh <command> <args> [options]` — <description>
...

All commands accept `--repo <owner/repo>` to target a specific repository (defaults to current repo).
```

Add, remove, or update commands as needed to match the source. Keep descriptions concise
(lowercase, no trailing period).

### 4. Commit and create PR

Follow the repository's PR rules. Use type `chore` and scope `claude`.
Example: `chore(claude): update claude-tools documentation`.
