# tmux cheatsheet

Personal shortcuts for this dotfiles setup. **Prefix = `Ctrl-a`** (written below as `C-a`).

> "C-a x" means: press `Ctrl-a`, release, then press `x`.
> `★` = custom binding from `tmux.conf`. Everything else is a tmux default.

## Panes — create / split

| Action | Keys | |
|---|---|---|
| Split left/right (new pane to the right) | `C-a \|` | ★ keeps current path |
| Split top/bottom (new pane below) | `C-a -` | ★ keeps current path |
| (default splits still work) | `C-a %` / `C-a "` | |
| Zoom / unzoom current pane | `C-a z` | |
| Close current pane | `C-a x` | |
| Close **all panes except** current | `C-a f` | ★ |

## Panes — navigate / resize

| Action | Keys | |
|---|---|---|
| Move focus left / down / up / right | `C-a h` / `C-a j` / `C-a k` / `C-a l` | ★ |
| Move focus (vim-aware, **no prefix**) | `C-h` / `C-j` / `C-k` / `C-l` | ★ via vim-tmux-navigator — jumps between vim splits & tmux panes |
| Resize pane (hold to repeat) | `C-a H` / `C-a J` / `C-a K` / `C-a L` | ★ repeatable, 5 cells |

## Windows

| Action | Keys | |
|---|---|---|
| New window (in current path) | `C-a c` | ★ keeps current path |
| Next / previous window | `C-a n` / `C-a p` | |
| Go to window by number | `C-a 1` … `C-a 9` | base index is 1 ★ |
| Rename window | `C-a ,` | |
| List / pick windows | `C-a w` | |
| Close window | `C-a &` | |

## Sessions

| Action | Keys | |
|---|---|---|
| New / switch project session (fzf over `~/dev`) | `C-a o` | ★ create-or-attach, popup |
| Rename session | `C-a $` | |
| List / switch sessions | `C-a s` | |
| Detach (leave session running) | `C-a d` | |
| Command prompt | `C-a :` | e.g. `:new-session -s work` |

## Copy mode (vi keys)

| Action | Keys | |
|---|---|---|
| Enter copy mode | `C-a [` | scroll with `h/j/k/l`, `C-u`/`C-d` |
| Start selection | `v` | ★ |
| Copy selection | `y` | ★ |
| Paste | `C-a ]` | |

## From the shell (no prefix needed)

```sh
tmux                       # start / attach default session
tmux new -s work           # new named session
tmux ls                    # list sessions
tmux attach -t work        # attach to a session
tmux rename-session new    # rename current session
```

## Notes
- `prefix` is remapped to `C-a` (not the tmux default `C-b`).
- `allow-rename off`: shells can't auto-rename windows — names stick until you set them with `C-a ,`.
- Windows & panes are **1-indexed** and renumber automatically when one closes.
- Plugins (via TPM): `tmux-sensible`, `catppuccin/tmux` (status bar theme), `vim-tmux-navigator`.
- Reload config after edits: `C-a :` then `source-file ~/.tmux.conf`.
