# `session mark-denials-collected`

Record that every denial up to and including `<timestamp>` has been triaged, so that later
[`list-denials`](list-denials.md) runs show only newer ones.

## Usage

```bash
claude-tools session mark-denials-collected <timestamp>
```

## Arguments

| Argument    | Required | Description                                                                          |
| ----------- | -------- | ------------------------------------------------------------------------------------ |
| `timestamp` | Yes      | The `timestamp` of the last denial that was triaged, as printed by `list-denials`    |

Pass the last triaged timestamp rather than "now": denials recorded while triaging would otherwise
be skipped.

The cursor is stored in `$XDG_STATE_HOME/claude-tools/denials-collected-through`
(`~/.local/state/claude-tools/…` by default), outside any repository.

## Example

```bash
$ claude-tools session mark-denials-collected 2026-09-19T13:38:56.158Z
Denials through 2026-09-19T13:38:56.158Z are marked as collected
```
