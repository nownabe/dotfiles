# `pre-write` — Forbidden Content Patterns

A `PreToolUse` hook that blocks `Write`, `Edit` and `NotebookEdit` calls whose content matches a
forbidden pattern.

`pre-bash` only ever sees the command line. Text that reaches a repository through a file — a commit
message passed with `git commit -F`, a pull request body passed with `gh pr create --body-file` —
is invisible to it. `pre-write` closes that gap by checking the content at the moment it is written.

## Setup

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "claude-hooks pre-write"
          }
        ]
      }
    ]
  }
}
```

## Configuration

Add a `preWrite` section to `.claude/nownabe-claude-hooks.json`. Entries have the same shape as
`preBash.forbiddenPatterns` (see [`pre-bash.md`](pre-bash.md#forbidden-patterns)); only
`forbiddenPatterns` is supported.

```json
{
  "preWrite": {
    "forbiddenPatterns": {
      "Co-Authored-By:\\s*Claude": {
        "type": "regex",
        "reason": "Claude Code attribution is forbidden in file content.",
        "suggestion": "Remove the attribution line."
      }
    }
  }
}
```

`preWrite` is deliberately a separate key from `preBash`: a pattern such as `^echo\b` is about the
command being run and must not match a file that merely mentions `echo`.

## What is checked

| Tool           | Field        |
| -------------- | ------------ |
| `Write`        | `content`    |
| `Edit`         | `new_string` |
| `NotebookEdit` | `new_source` |

Other tools contribute nothing and are never denied.

## Private patterns

In addition to the config, `pre-write` enforces the machine-local private patterns described in
[`private-patterns.md`](private-patterns.md). They are judged by **where the file lives**, not by the
session's working directory: a file inside a private repository's worktree may name private things,
while a scratch file outside any repository may be published next.

Files under `~/.claude/` and the pattern files themselves are exempt, so memory, settings and the
pattern lists can name what they need to.
