#!/usr/bin/env bash
# Fuzzy-pick a project dir and create-or-attach a tmux session named after it.
# Bound to `C-a o` in tmux.conf. Session name = dir basename (dots -> underscores).

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/dev -mindepth 1 -maxdepth 1 -type d | sort | fzf)
fi

[[ -z $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# Not inside tmux and no server running: just start a session here.
if [[ -z $TMUX && -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

# Create the session detached if it doesn't exist yet.
if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

# Attach (from outside tmux) or switch (from inside tmux).
if [[ -z $TMUX ]]; then
    tmux attach-session -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
