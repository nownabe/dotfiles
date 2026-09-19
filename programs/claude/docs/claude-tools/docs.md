# `docs`

Print the documentation for `claude-tools` commands and `claude-hooks` hooks. Without a name it prints a one-line-per-doc index; with a name it prints that doc as Markdown, so an agent reads only what it needs.

## Usage

```bash
claude-tools docs
claude-tools docs <name>
```

## Arguments

| Argument | Required | Description                                                                                                 |
| -------- | -------- | ----------------------------------------------------------------------------------------------------------- |
| `name`   | No       | A doc name from the index. Any unique trailing part works, and words may replace slashes (`gh get-release`) |

Docs are read from `programs/claude/docs/` in the dotfiles working tree, so a page is available as soon as its file exists.

## Examples

```bash
# List every doc with a one-line summary
claude-tools docs

# These all print docs/claude-tools/gh/get-release.md
claude-tools docs claude-tools/gh/get-release
claude-tools docs gh/get-release
claude-tools docs get-release
claude-tools docs gh get-release

# Hook reference
claude-tools docs pre-bash
```

## Exit status

`1` with a message on stderr when the name matches no doc or more than one; the ambiguous case lists the candidates.
