#!/bin/sh
# Emit the tmux window-status waiting glyph for one window, tracking a persistent
# "seen" state so a viewed-but-unanswered waiter does not revert to the unseen
# glyph after you switch away. Called from window-status{,-current}-format via
# #(...) on every status redraw (status-interval), once per window.
#
#   tmux-claude-glyph <window_id> <active>   # active: 1 for the focused window, else 0
#
# A window is "waiting" when its active pane's #{pane_title} starts with the Claude
# idle glyph (U+2733 ✳). While Claude works the title carries a braille spinner
# (U+2800-U+28FF) instead, and once you reply it loses the glyph entirely — both are
# "not waiting", which clears the seen flag so the next idle cycle rearms 🔔.
#
# Glyphs: 👀 waiting + focused (looking now); 👁 waiting + seen earlier but not
# focused (walked away, still unanswered); 🔔 waiting + never seen.
wid="$1"
active="$2"

title=$(tmux display-message -p -t "$wid" '#{pane_title}' 2>/dev/null)
seen=$(tmux show-options -wqv -t "$wid" @claude_seen 2>/dev/null)
[ -z "$seen" ] && seen=0

# Literal ✳ prefix match. sh `case` matches a literal pattern byte-wise, so this is
# locale-independent (#() children may not inherit a UTF-8 locale).
case "$title" in
  ✳*)
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
    [ "$seen" = "0" ] || tmux set-option -w -t "$wid" @claude_seen 0
    ;;
esac
