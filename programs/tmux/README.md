# tmux

Prefix: `Ctrl+X`.

## Keybindings

### Alt (prefix-free)

| Key | Action |
|---|---|
| `Alt+h` | Previous window |
| `Alt+l` | Next window |
| `Alt+j` | Next session |
| `Alt+k` | Previous session |

### Prefix (`Ctrl+X`) +

| Key | Action |
|---|---|
| `h/j/k/l` | Pane navigation (left/down/up/right) |
| `\` | Split pane below |
| `\|` | Split pane right |
| `R` | Enter resize mode |
| `n` | New window |
| `s` | Session selector (tree view) |
| `S` | New session (prompts for name) |
| `r` | Rename session |
| `Space` | Enter copy mode |
| `v` | Paste buffer |
| `d` | Detach from session |
| `x` | Send `Ctrl+X` to shell |

### Resize Mode (`Prefix+R`)

| Key | Action |
|---|---|
| `h/j/k/l` | Resize pane (repeatable) |
| `Escape` | Exit resize mode |

### Copy Mode (`Prefix+Space`)

| Key | Action |
|---|---|
| `v` | Begin selection |
| `V` | Select line |
| `Ctrl+v` | Toggle rectangle selection |
| `y` | Yank and exit (OSC 52 clipboard) |
| `q` / `Escape` | Cancel |

Vi navigation keys (`h/j/k/l`, `w/b/e`, `0/^/$`, `g/G`, `Ctrl+u/d/b/f`, `f/F/t/T`, `/`, `n/N`) work in copy mode via `keyMode = "vi"`.

## Common Commands

| Command | Description |
|---|---|
| `tmux` | Start new session |
| `tmux attach` | Attach to last session |
| `tmux attach -t <name>` | Attach to named session |
| `tmux source-file ~/.config/tmux/tmux.conf` | Reload config (also works from `prefix+:`) |
