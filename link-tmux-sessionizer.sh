rm -f ~/.local/bin/tmux-sessionizer
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p ~/.local/bin
ln -sv $DOTFILES_DIR/tmux-sessionizer.sh ~/.local/bin/tmux-sessionizer
chmod +x $DOTFILES_DIR/tmux-sessionizer.sh
