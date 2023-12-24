rm -fr ~/.gitconfig

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig

