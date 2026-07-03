rm -f ~/.local/bin/tmux-claude-title
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p ~/.local/bin
ln -sv $DOTFILES_DIR/tmux-claude-title.sh ~/.local/bin/tmux-claude-title
chmod +x $DOTFILES_DIR/tmux-claude-title.sh
