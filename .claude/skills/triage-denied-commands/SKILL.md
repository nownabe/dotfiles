---
name: triage-denied-commands
description: >
  Collect the commands Claude Code did not execute — blocked by a hook or permission rule, by the
  auto mode classifier, or rejected at the prompt — from sessions not yet triaged, and decide per
  group whether to turn it into a claude-tools command (with a hook that steers Claude to it), allow
  it explicitly, block it explicitly, or keep it as is. Use when the user asks to review blocked,
  denied or stopped commands, or to tune the allow/deny rules from session history (e.g.,
  "止められたコマンドを整理して", "通らなかったコマンドを集めて", "denied commands を triage して",
  "許可リストを見直して").
---

# Triage Denied Commands

Turn the commands Claude Code refused into rule changes. Everything edited here lives in the
dotfiles repository, which is **public** — read "Secrets" before touching a file.

## Secrets

The collected commands are whatever sessions tried to run: private hostnames, ports, paths,
credentials inside URLs. Showing them in chat is fine (it stays on this machine); the repository,
commit messages and GitHub are not.

- Never copy a collected `command`, `cwd` or `reason` into a file in the repository, a commit
  message, or a PR title/body. Write patterns from the command **name and flags** only
  (`gh api *`, `^ssh\b`), never from hosts, paths or other arguments.
- Commit and PR text describe the mechanism ("allow `gh api` reads", "forbid `sed`, point to
  Edit"), not what prompted it: no incident narrative, no description of private infrastructure,
  no names of other repositories.
- The global pre-commit hook rejects staged lines matching `~/.config/git/private-patterns`. Fix
  what it reports; never bypass it.
- `programs/claude/settings.json` is the live `~/.claude/settings.json`, so Claude Code writes
  runtime state into it (e.g. `autoMode.environment`, which can describe private hosts). Before
  committing it, review `git diff programs/claude/settings.json` and stage only the permission
  hunks with `git add -p`. Report any other hunk to the user instead of committing it.
- Nothing about the triage itself is committed: the cursor lives in
  `$XDG_STATE_HOME/triage-denied-commands/`, outside any repository.

## Workflow

The collector is `denials.ts` next to this file. Run it from the repository root; it reads only the
transcripts and its own state directory:

```bash
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/triage-denied-commands"
deno run --allow-env=HOME,XDG_STATE_HOME --allow-read="$HOME/.claude/projects,$STATE" --allow-write="$STATE" .claude/skills/triage-denied-commands/denials.ts <list|mark> ...
```

(`deno test --allow-read --allow-write .claude/skills/triage-denied-commands/` runs its check.)

### 1. Collect

```bash
… denials.ts list        # sessions not yet triaged
… denials.ts list --all  # everything on record (re-triage)
```

One JSON line per denial, oldest first: `timestamp`, `sessionId`, `cwd`, `kind`, `tool`,
`command`, `reason`. Note the `timestamp` of the last line — step 5 needs it. If nothing is listed,
tell the user and stop.

### 2. Group

```bash
… denials.ts list --summary   # add --all to match step 1
```

One line per group, largest first: `count`, what stopped the call, the group, one example command.
The stopper column is derived from `kind` and `reason`:

| Stopper       | Grouped by                               | Meaning                                                                         |
| ------------- | ---------------------------------------- | ------------------------------------------------------------------------------- |
| `hook`        | the rule's `reason`                      | a `forbiddenPatterns` rule in `nownabe-claude-hooks.json`, or a repo-local hook |
| `rule/prompt` | command name (`cd …`, `VAR=`, `timeout` peeled off) | a `permissions.deny` rule, or the prompt was declined                 |
| `automode`    | command name                             | the auto mode classifier                                                        |
| `user`        | command name                             | the user, at the prompt                                                         |

Merge groups that are one decision (all `hook` rows usually are) and split a row when its example
shows two different tasks — the JSON from step 1 has the full commands. Show the user one table:
group, count, what stopped it, one representative command (verbatim is fine in chat), and your
recommendation. Recommend:

- **Keep as is** for hook denials whose `suggestion` already steers Claude to the right tool — the
  rule is doing its job. Recommend a change only when the suggestion misleads or the match is a
  false positive.
- **Allow** for read-only or otherwise routine commands the user has been approving by hand.
- **Block** for commands the user keeps rejecting, or that a deny rule catches but Claude keeps
  retrying — a forbidden pattern carries a suggestion, a deny rule does not.
- **Tool** when a group is one recurring task (fetching the same kind of data with `curl` or
  `gh api`, say) that a small `claude-tools` command would do with fixed, safe arguments.

### 3. Decide

Ask with `AskUserQuestion`, one question per group, the recommended option first with
`(Recommended)`. The options are exactly: Tool, Allow, Block, Keep as is. A group the user does not
decide is "Keep as is".

### 4. Apply

The changes get their own PR: branch from `origin/main` before editing anything.

#### Tool (with hook steering)

1. Add `programs/claude/tools/<group>/<name>.ts` in the style of the `gh/` commands: the logic in
   an exported function that takes its runner as a parameter, `main()` parsing
   `Deno.args.slice(2)`, a `<name>.test.ts`, an entry in the group's `index.ts` (a new group also
   goes into `tools/cli.ts`). Hosts and secrets are never arguments or literals; read them from the
   environment or a machine-local file at run time.
2. If the tool needs more than the wrapper's Deno permissions, extend them in
   `programs/claude/default.nix` (the user must run `hms` afterwards).
3. Document it in `programs/claude/docs/claude-tools/<group>/<name>.md` and in the command list of
   `programs/claude/CLAUDE.md`.
4. Steer Claude to it: with the `edit-nownabe-claude-hooks` skill, add a `forbiddenPatterns` rule
   for the raw command whose `suggestion` names the new command
   (``Use `claude-tools <group> <name>` instead.``). `Bash(claude-tools:*)` is already allowed.
5. `cd programs/claude && deno task check`.

#### Allow

- Default: a prefix rule in `permissions.allow` of `programs/claude/settings.json`,
  `Bash(<cmd> <subcmd>:*)`, as narrow as the actual usage (`gh api` yes, `curl` no). If a
  `permissions.deny` rule caused the denial, narrow or remove that rule — deny wins over allow.
- Only when multi-line matching or a regex is needed: `allowedPatterns` in
  `nownabe-claude-hooks.json`, via `edit-nownabe-claude-hooks`.
- Never allow a command that reaches the network with caller-supplied URLs, elevates privileges,
  or is destructive.

#### Block

With `edit-nownabe-claude-hooks`, add a `forbiddenPatterns` rule anchored on the command name
(`^cmd\b`) with a `reason` and a `suggestion` that tells Claude what to do instead. Prefer this over
`permissions.deny`: the suggestion is what stops the retries. Test it against the hook as that
skill describes.

#### Keep as is

Nothing to edit.

### 5. Mark collected

```bash
… denials.ts mark <timestamp of the last line from step 1>
```

Pass that timestamp, not "now", so denials recorded while triaging are not skipped. Do this even
when every decision was "Keep as is", so the next run starts after these.

### 6. Verify, commit, PR

- `jq empty programs/claude/nownabe-claude-hooks.json programs/claude/settings.json`
- `cd programs/claude && deno task check` when any `.ts` changed
- Reread the staged diff against "Secrets" above

Then commit and open a PR per the repository's rules — one PR per triage, type `feat`, scope
`claude`, e.g. `feat(claude): allow gh api reads and forbid raw curl`. The body lists the rules and
tools changed, nothing more.
