rm -fr ~/.tmux.conf
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf

