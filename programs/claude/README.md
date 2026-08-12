# Claude Code Configuration

## skills/

Global skills, symlinked to `~/.claude/skills` by Home Manager.

### Vendored skills

The following skills are copied from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, Copyright (c) 2026 Matt Pocock) at commit `84fdeffd12f2ee307994d1eb6feb48173b6e0502`. Only the `SKILL.md` (and its reference docs) are vendored; the upstream `agents/openai.yaml` files are Codex-specific and omitted. Content is unchanged apart from `oxfmt` reformatting (emphasis markers, table padding).

| Skill             | Invocation    | Upstream path                        |
| ----------------- | ------------- | ------------------------------------ |
| `grilling`        | Model or user | `skills/productivity/grilling`       |
| `grill-me`        | User only     | `skills/productivity/grill-me`       |
| `grill-with-docs` | User only     | `skills/engineering/grill-with-docs` |
| `domain-modeling` | Model or user | `skills/engineering/domain-modeling` |

`grill-me` and `grill-with-docs` are thin entrypoints that delegate to `grilling`; `grill-with-docs` additionally uses `domain-modeling`. To refresh, re-copy from upstream and update the commit above.

## pre-bash.json

Configuration file for the `pre-bash.ts` PreToolUse hook, which validates Bash commands before execution.

The hook loads `.claude/pre-bash.json` from CWD up to HOME, merging all found files. Child-level (closer to CWD) entries take priority over parent-level (closer to HOME) entries.

Default config is deployed to `~/.claude/pre-bash.json` via Home Manager. Projects can add their own `.claude/pre-bash.json` to extend or override the defaults.

### Schema

```json
{
  "forbiddenPatterns": [
    {
      "pattern": "<regex>",
      "reason": "<message shown to Claude>",
      "suggestion": "<guidance for alternative approach>"
    }
  ]
}
```

### Fields

#### `forbiddenPatterns`

A list of regex patterns to deny. Each entry has:

| Field        | Type      | Required              | Description                                |
| ------------ | --------- | --------------------- | ------------------------------------------ |
| `pattern`    | `string`  | Yes                   | Regex pattern to match against the command |
| `reason`     | `string`  | Yes (unless disabled) | Why the command is forbidden               |
| `suggestion` | `string`  | Yes (unless disabled) | Alternative approach for Claude            |
| `disabled`   | `boolean` | No                    | Set to `true` to disable this pattern      |

### Overriding parent patterns

To disable a pattern defined in a parent-level config, re-declare it with `disabled: true` in a child-level config:

```json
{
  "forbiddenPatterns": [{ "pattern": "\\bgit\\s+-C\\b", "disabled": true }]
}
```

When the same `pattern` string appears in multiple files, the child-level entry wins.
