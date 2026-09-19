# `session list-denials`

List the tool calls Claude Code did not execute — blocked by a permission rule or hook, by the auto
mode classifier, or rejected at the prompt — across every session transcript under
`~/.claude/projects`. By default only denials newer than the collected-through cursor are shown
(see [`mark-denials-collected`](mark-denials-collected.md)).

## Usage

```bash
claude-tools session list-denials [--all]
```

## Options

| Option  | Description                                          |
| ------- | ---------------------------------------------------- |
| `--all` | Ignore the cursor and list every denial on record    |

## Output

One JSON object per line on stdout, oldest first; the count and the cursor in effect go to stderr.

```json
{"timestamp":"2026-09-19T13:38:56.158Z","sessionId":"63aabc48-…","cwd":"/path/to/project","kind":"permission-rule","tool":"Bash","command":"echo hi","reason":"PreToolUse:Bash hook error: `echo` is forbidden. …"}
```

| Field     | Description                                                                                                   |
| --------- | ------------------------------------------------------------------------------------------------------------- |
| `kind`    | Claude Code's `toolDenialKind`: `permission-rule`, `automode-blocked`, `automode-unavailable`, `user-rejected` |
| `tool`    | The tool that was called                                                                                      |
| `command` | The Bash command line; for other tools the file path or URL, else the raw input                              |
| `reason`  | The message the denied call received                                                                          |

`AskUserQuestion` rejections are omitted: they are answers to Claude, not blocked commands.

The output is whatever sessions tried to run — it can include private hostnames, paths and
credentials. Keep it out of any repository.
