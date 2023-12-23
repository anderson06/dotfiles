# clean
# rm -fr ~/.gitconfig
# rm -fr ~/.tmux.conf
rm -fr ~/.config/nvim/init.lua

# create dirs
mkdir -p ~/.config/nvim/

# link
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
# ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
ln -sv $DOTFILES_DIR/init.lua ~/.config/nvim/init.lua
