# Claude Code Configuration

Everything Home Manager deploys to `~/.claude`, plus the two Deno CLIs it puts on `PATH`.

Previously these CLIs lived in [`nownabe/claude`](https://github.com/nownabe/claude) and were
invoked with `bunx @nownabe/claude-{tools,hooks}`. That repo is retired; the sources moved here and
now run on Deno.

## CLIs

`programs/claude/default.nix` installs two wrappers that `deno run` the TypeScript in this
directory **straight from the working tree**, so editing a `.ts` file takes effect immediately —
no `hms` needed. Only `default.nix` changes require a rebuild.

| Command                          | Entrypoint     | Deno permissions                                                                         |
| -------------------------------- | -------------- | ---------------------------------------------------------------------------------------- |
| `claude-tools <group> <command>` | `tools/cli.ts` | `--allow-run=gh`, `--allow-read` for `docs/`                                             |
| `claude-hooks <hook>`            | `hooks/cli.ts` | `--allow-read`, `--allow-env=HOME,XDG_CONFIG_HOME`, `--allow-run` for git and PowerShell |

Both run with `--no-remote`, so neither may import anything outside the standard library — they
start offline and fast, which matters because `pre-bash` runs on every Bash tool call. JSR
dependencies (`@std/testing`, `@std/expect`) are test-only.

- `tools/` — GitHub utilities, plus `claude-tools docs [name]`, which prints the Markdown under
  [`docs/`](docs/) so agents can read a command's reference on demand instead of loading it all
  into context. See [`docs/claude-tools/`](docs/claude-tools/).
- `hooks/` — `pre-bash`, `pre-write` and `notification` hooks. See
  [`docs/claude-hooks/`](docs/claude-hooks/). `pre-bash` and `pre-write` also enforce the
  machine-local [private patterns](docs/claude-hooks/private-patterns.md) shared with the global
  git hooks in `programs/git/hooks/`.

### Development

```bash
cd programs/claude
deno task check   # fmt --check + lint + type check + test
deno task test
```

## settings.json

`programs/claude/settings.json` holds the settings distributed to every machine: hooks,
permissions, plugins, status line. It is **not** linked into `~/.claude/settings.json` — Claude Code
writes machine-local state there at runtime (the chosen model, the auto-mode environment profile,
notification flags), and a link would turn every such write into an uncommitted change to a public
file.

Instead, `hms` deep-merges the managed keys into the live file: managed keys win, everything else
stays as Claude Code wrote it. Consequences:

- Runtime choices such as `model` survive `hms`; keep them out of the managed file.
- Arrays (`permissions.allow`, hook lists) are replaced wholesale, so a rule added through the Claude
  Code UI lasts until the next `hms` unless it is added here too.
- Removing a key from the managed file does not remove it from the live file; delete it by hand.

## nownabe-claude-hooks.json

Configuration for both hooks, deployed to `~/.claude/nownabe-claude-hooks.json`. The hooks load
every `.claude/nownabe-claude-hooks.json` (and `.local.json`) from CWD up to `$HOME` and deep merge
them, with directories closer to CWD winning.

See [`docs/claude-hooks/pre-bash.md`](docs/claude-hooks/pre-bash.md) for the pattern syntax,
[`docs/claude-hooks/pre-write.md`](docs/claude-hooks/pre-write.md) for the content check and
[`docs/claude-hooks/notification.md`](docs/claude-hooks/notification.md) for sound configuration.
The `edit-nownabe-claude-hooks` skill in `.claude/skills/` edits this file safely.

## skills/

Global skills, symlinked file-by-file into `~/.claude/skills` so unmanaged local skills can
coexist there. New files require re-running `hms` to be linked.

`gh-create-issue` came from the `base` plugin of the retired `nownabe/claude` marketplace.

### Vendored skills

The following skills are copied from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, Copyright (c) 2026 Matt Pocock) at commit `84fdeffd12f2ee307994d1eb6feb48173b6e0502`. Only the `SKILL.md` (and its reference docs) are vendored; the upstream `agents/openai.yaml` files are Codex-specific and omitted. Apart from the local changes noted below, content differs from upstream only by reformatting (emphasis markers, table padding).

| Skill             | Invocation    | Upstream path                        | Local changes              |
| ----------------- | ------------- | ------------------------------------ | -------------------------- |
| `grilling`        | Model or user | `skills/productivity/grilling`       | Asks via `AskUserQuestion` |
| `grill-me`        | User only     | `skills/productivity/grill-me`       | —                          |
| `grill-with-docs` | User only     | `skills/engineering/grill-with-docs` | —                          |
| `domain-modeling` | Model or user | `skills/engineering/domain-modeling` | —                          |

`grill-me` and `grill-with-docs` are thin entrypoints that delegate to `grilling`; `grill-with-docs` additionally uses `domain-modeling`.

`grilling` is locally modified: upstream asks the whole frontier as numbered prose, this copy drives the same rounds through the `AskUserQuestion` tool with pre-computed options and a marked recommendation, keeping prose only for questions that genuinely have no enumerable answers. Re-copying it from upstream would drop that — diff before overwriting. The other three can be refreshed by straight re-copy; update the commit above when you do.
