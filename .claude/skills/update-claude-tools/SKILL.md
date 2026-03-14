---
name: update-claude-tools
description: >
  Update @nownabe/claude-tools and @nownabe/claude-hooks documentation in the dotfiles repository
  to match the latest commands and hooks from the source repository. Use when the user asks to
  update, sync, or refresh claude-tools or claude-hooks documentation (e.g., "update claude-tools",
  "sync claude-tools docs", "@nownabe/claude-tools を最新化して").
---

# Update Claude Tools

Update `programs/claude/CLAUDE.md` in the dotfiles repo to reflect the latest commands and hooks
from the `nownabe/claude` source repository.

## Source

Read `README.md` from `/home/nownabe/src/github.com/nownabe/claude`.

It contains two tables:
- **Tools** table — `Command | Description` for `@nownabe/claude-tools`
- **Hooks** table — `Hook | Description` for `@nownabe/claude-hooks`

For detailed usage (arguments, options) of each command, read
`docs/claude-tools/gh/<command>.md` from the same repo.

## Target

`programs/claude/CLAUDE.md` in this repo (deployed as `~/.claude/CLAUDE.md` via Home Manager).

## Workflow

1. **Read source**: Read `/home/nownabe/src/github.com/nownabe/claude/README.md` to get the
   current command and hook lists.

2. **Read command docs**: For each command, read `docs/claude-tools/gh/<command>.md` from the
   source repo to extract the usage pattern (arguments and options).

3. **Update CLAUDE.md**: Update the `## @nownabe/claude-tools` section in `programs/claude/CLAUDE.md`.
   Preserve the existing format:

   ```markdown
   ## @nownabe/claude-tools

   `@nownabe/claude-tools` provides GitHub-related CLI utilities. Run via `bunx @nownabe/claude-tools <command>`.

   Available commands:

   - `gh <command> <args> [options]` — <description>
   ...

   All commands accept `--repo <owner/repo>` to target a specific repository (defaults to current repo).
   ```

4. **Commit and create PR**: Follow the repository's PR rules (Conventional Commits, labels, etc.).
   Use type `chore` and scope `claude`. Example: `chore(claude): update claude-tools documentation`.
