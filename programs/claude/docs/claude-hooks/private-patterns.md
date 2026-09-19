# Private patterns

One machine-local list of things that must never reach a public place, enforced everywhere text
leaves the machine:

| Where                                              | Enforced by                                        |
| -------------------------------------------------- | -------------------------------------------------- |
| Staged content                                     | global `pre-commit` git hook                       |
| Commit messages (`-m`, `-F`, `--amend`, `$EDITOR`) | global `commit-msg` git hook                       |
| Files Claude Code writes                           | `claude-hooks pre-write`                           |
| Commands Claude Code runs that publish text        | `claude-hooks pre-bash` (`gh pr`, `git commit`, …) |

## Files

Both live in `$XDG_CONFIG_HOME/git` (default `~/.config/git`), one extended regular expression per
line, matched case-insensitively. `#` comments and blank lines are ignored.

| File               | Contents                                                                            |
| ------------------ | ----------------------------------------------------------------------------------- |
| `private-patterns` | What must never appear: internal hostnames, IPs, ports, private repository names.   |
| `private-remotes`  | Origin URLs of private repositories. Where the origin matches, nothing is enforced. |

`hms` seeds comment-only templates if the files do not exist and never touches existing ones.

The lists stay outside every repository on purpose: what they name is the very thing worth keeping
out of a public one. The repository ships the mechanism; the machine supplies the content.

## Deciding "private"

A repository is private when `git remote get-url origin` matches a line of `private-remotes`.
Everything else — including a directory with no remote at all — is treated as public. That is
deliberate: a pull request body is written to a scratch file outside any repository before
`--body-file` publishes it.

With an empty `private-patterns` nothing is enforced, so a fresh machine works normally until its
owner fills the file in.

## Scope

- Git hooks scan **added** lines only. Content already committed is already public, and flagging it
  would fail every later commit that touches the file without changing what is exposed.
- `pre-bash` checks only sub-commands that publish text: `gh pr|issue|release|repo|gist|api` and
  `git commit|tag|merge|notes`. Cloning a private remote or grepping for its name publishes nothing.
- `pre-write` exempts files under `~/.claude/` and the two pattern files themselves.

## Keep the patterns simple

The same lines are read by `grep -iE` and by JavaScript `RegExp`. Escaped literals
(`git\.example\.invalid`, `:1234`), character classes and alternation behave the same in both;
avoid engine-specific syntax such as lookbehind or `\b` inside brackets.
