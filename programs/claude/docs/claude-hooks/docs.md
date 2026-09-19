# `docs`

Print the documentation for `claude-hooks` hooks and their configuration. Without a name it prints a one-line-per-doc index; with a name it prints that doc as Markdown. `claude-tools docs` does the same for the tools.

## Usage

```bash
claude-hooks docs
claude-hooks docs <name>
```

## Examples

```bash
# List every doc with a one-line summary
claude-hooks docs

# Pattern syntax for nownabe-claude-hooks.json
claude-hooks docs pre-bash

# The machine-local private-patterns list shared with the git hooks
claude-hooks docs private-patterns
```

## Exit status

`1` with a message on stderr when the name matches no doc or more than one; the ambiguous case lists the candidates.
