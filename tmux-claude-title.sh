#!/bin/sh
# Rename the current tmux window to its Claude Code session title.
#
# Claude writes its generated title into the pane's OSC title, which tmux keeps
# in #{pane_title} even under `allow-rename off`. The title is prefixed with a
# status glyph (U+2733 idle, or a braille spinner U+2800-U+28FF while working).
# That leading glyph is the reliable "this is a Claude pane" signal: strip it to
# get the title; if it is absent the pane is not Claude and we leave it alone.
# Cap the displayed name so long titles do not overflow the tmux status bar.
MAX_TITLE_CHARS=40

pane="${TMUX_PANE:-}"
title=$(tmux display-message ${pane:+-t "$pane"} -p '#{pane_title}')

# perl prints only when a leading Claude glyph was present -> empty output means
# "not a Claude pane", so we skip the rename instead of blanking the window name.
# Titles over MAX_TITLE_CHARS are truncated at a word boundary with a trailing
# ellipsis; length is measured in characters (perl -CSDA), not bytes.
clean=$(printf '%s' "$title" | MAX_TITLE_CHARS="$MAX_TITLE_CHARS" perl -CSDA -ne '
  if (s/^\s*[\x{2733}\x{2800}-\x{28FF}]+\s*//) {
    s/\s+$//;
    my $lim = $ENV{MAX_TITLE_CHARS};
    if (length > $lim) {
      my $t = substr($_, 0, $lim);
      $t =~ s/\s+\S*$// if $t =~ /\s/;   # back up to the last whole word
      $t =~ s/\s+$//;
      $_ = $t . "\x{2026}";
    }
    print;
  }
')

if [ -n "$clean" ]; then
  tmux rename-window ${pane:+-t "$pane"} -- "$clean"
  tmux set-window-option ${pane:+-t "$pane"} automatic-rename off
else
  tmux display-message "tmux-claude-title: no Claude title in pane_title"
fi
