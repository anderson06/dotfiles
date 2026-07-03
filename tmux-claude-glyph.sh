#!/bin/sh
# Emit the tmux window-status glyph for one window from its Claude session status,
# tracking a persistent "seen" flag so a viewed-but-unanswered idle waiter does not
# revert to the unseen glyph after you switch away. Called from
# window-status{,-current}-format via #(...) on every status redraw, once per window:
#
#   tmux-claude-glyph <window_id> <active>   # active: 1 for the focused window, else 0
#
# The @claude_status option is stamped per window by `claude-dash --emit-tmux`
# (run from a zero-width status-right #(); see tmux.conf). Values: waiting|busy|
# idle|done, or unset when the window hosts no Claude session.
#
# Glyphs: 🔵 busy (working); ⏳ waiting (blocked on your input mid-task); ✅ done
# (session ended); and for idle (turn finished, awaiting your reply) the seen/focus
# escalation — 👀 focused, 👁 seen earlier but not focused (walked away), 🔔 never
# seen. Non-idle states clear the seen flag so the next idle cycle rearms 🔔.
wid="$1"
active="$2"

status=$(tmux show-options -wqv -t "$wid" @claude_status 2>/dev/null)
seen=$(tmux show-options -wqv -t "$wid" @claude_seen 2>/dev/null)
[ -z "$seen" ] && seen=0

clear_seen() { [ "$seen" = "0" ] || tmux set-option -w -t "$wid" @claude_seen 0; }

case "$status" in
  busy)    clear_seen; printf '🔵 ' ;;
  waiting) clear_seen; printf '⏳ ' ;;
  done)    clear_seen; printf '✅ ' ;;
  idle)
    if [ "$active" = "1" ]; then
      [ "$seen" = "1" ] || tmux set-option -w -t "$wid" @claude_seen 1
      printf '👀 '
    elif [ "$seen" = "1" ]; then
      printf '👁 '
    else
      printf '🔔 '
    fi
    ;;
  *)
    clear_seen
    ;;
esac
