# Claude Code Configuration

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

| Field | Type | Required | Description |
|---|---|---|---|
| `pattern` | `string` | Yes | Regex pattern to match against the command |
| `reason` | `string` | Yes (unless disabled) | Why the command is forbidden |
| `suggestion` | `string` | Yes (unless disabled) | Alternative approach for Claude |
| `disabled` | `boolean` | No | Set to `true` to disable this pattern |

### Overriding parent patterns

To disable a pattern defined in a parent-level config, re-declare it with `disabled: true` in a child-level config:

```json
{
  "forbiddenPatterns": [
    { "pattern": "\\bgit\\s+-C\\b", "disabled": true }
  ]
}
```

When the same `pattern` string appears in multiple files, the child-level entry wins.
