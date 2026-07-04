---
name: edit-nownabe-claude-hooks
description: >
  Add or edit rules in nownabe-claude-hooks.json (the @nownabe/claude-hooks config) in the dotfiles
  repository — forbiddenPatterns, allowedPatterns, and notification sounds. NOT for Claude Code's
  built-in hooks in settings.json. Encodes the hook's command-matching semantics so patterns are
  written correctly and validated. Use when the user asks to forbid/allow a command, add a pre-bash
  rule, or edit nownabe-claude-hooks.json (e.g., "echo コマンドを禁止して", "gh を許可リストに追加",
  "nownabe-claude-hooks にルールを足して").
---

# Edit Claude Hooks

Add or edit rules in `programs/claude/nownabe-claude-hooks.json`. This file configures
`@nownabe/claude-hooks` and is deployed to `~/.claude/nownabe-claude-hooks.json` via Home Manager
(an out-of-store symlink, so **edits to the source file are live immediately** — no `hms` needed to
test).

## Config schema

```jsonc
{
  "notification": {
    "sounds": { "<event-or-*>": "<path-to-.wav>" }
  },
  "preBash": {
    "allowedPatterns": {
      "<pattern>": {
        "reason": "<why (optional, shown to user)>",
        "type": "glob" | "regex",   // optional; omitted → auto-detect
        "multiline": true,           // optional; `.` matches newlines
        "disabled": true             // optional; turn a rule off without deleting
      }
    },
    "forbiddenPatterns": {
      "<pattern>": {
        "reason": "<why it's forbidden>",       // REQUIRED
        "suggestion": "<what to do instead>",   // REQUIRED
        "type": "glob" | "regex",   // optional
        "multiline": true,           // optional
        "disabled": true             // optional
      }
    }
  }
}
```

- **forbiddenPatterns** deny a command (checked first — deny beats allow). Both `reason` and
  `suggestion` are required.
- **allowedPatterns** bypass the permission prompt. A compound command is auto-approved **only if
  every sub-command matches** some allowed pattern (so `dangerous && git commit` is not approved).

## How matching works (critical)

Before matching, the hook transforms the command (`src/pre-bash.ts` in `@nownabe/claude-hooks`):

1. **Split on shell operators** `&&`, `||`, `;`, `|` (operators inside single/double quotes are
   ignored). Each sub-command is **trimmed**.
2. **Expand `sh -c` / `bash -c`** — the inner command string is extracted and split recursively, so
   both the outer and inner commands are checked.
3. Each pattern is tested against **each sub-command** with `RegExp.test` (substring match unless
   anchored).

Consequences for writing patterns:

- A command name is always at the **start** of a sub-command. Anchor forbidden patterns with `^`
  (e.g. `^echo\b`) so you match the command being run, not the same word inside a quoted argument
  (e.g. `git commit -m "echo test"` must not trip an `echo` rule).
- You do **not** need to account for `|`, `&&`, `;` yourself — the splitter already isolates each
  sub-command. Matching `^echo\b` still catches `foo | echo x` because `echo x` is its own
  sub-command.
- `\b` is a JSON string, so backslashes must be escaped: write `"^echo\\b"`.

### Pattern types

- `type: "regex"` — the pattern is a JavaScript regex body (no delimiters). Escape backslashes for
  JSON.
- `type: "glob"` — Claude Code Bash-permission glob:
  - `*` is a wildcard.
  - `cmd *` (space before `*`) enforces a word boundary — matches `cmd` alone or `cmd <anything>`.
  - `cmd*` (no space) matches any string starting with `cmd`.
- `type` omitted → auto-detect: `/body/flags` is a regex, everything else is a glob.

## Workflow

### 1. Choose the rule

Decide forbidden vs allowed, and glob vs regex. Prefer a **glob** for simple prefix rules
(`git -C *`) and a **regex** when you need anchoring or alternation (`^echo\b`,
`\bgit\b.*\$\(cat\b`). Keep `reason`/`suggestion` concise and actionable.

### 2. Edit the JSON

Edit `programs/claude/nownabe-claude-hooks.json` with the Write/Edit tools. Add the rule under the
correct key, matching the existing entries' style.

### 3. Validate JSON

```bash
jq empty programs/claude/nownabe-claude-hooks.json
```

Confirm the new rule is present, e.g.:

```bash
jq -e '.preBash.forbiddenPatterns["^echo\\b"]' programs/claude/nownabe-claude-hooks.json
```

### 4. Test the rule against the hook

Feed a crafted hook input to the pre-bash hook and inspect the decision. Point `cwd` at a temp
directory that contains a `.claude/` copy of the edited config so you test **exactly the edited
file** (independent of deployment):

```bash
mkdir -p /tmp/ch-test/.claude
cp programs/claude/nownabe-claude-hooks.json /tmp/ch-test/.claude/
```

Write the test input (use the Write tool, not `echo`), e.g. `/tmp/ch-input.json`:

```json
{ "tool_input": { "command": "echo hello" }, "cwd": "/tmp/ch-test" }
```

Run it:

```bash
bunx @nownabe/claude-hooks pre-bash < /tmp/ch-input.json | jq .
```

- A matching **forbidden** rule → `"permissionDecision": "deny"` with your reason/suggestion.
- A matching **allowed** rule → `"permissionDecision": "allow"`.
- No match → empty output (the hook exits without an opinion).

Test both a command that **should** trip the rule and one that should **not** (e.g. the command name
appearing inside a quoted argument) to catch false positives.

### 5. Deploy and PR (only when asked)

The source symlink makes edits live immediately for testing, but a clean apply is `hms`. Do **not**
commit, push, or run `hms` unless the user asks. When they do, follow the repository's PR rules —
type `feat`/`chore`/`fix` with scope `claude`
(e.g. `feat(claude): forbid echo command in pre-bash hook`).
