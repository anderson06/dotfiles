# Link /nvim/ to ~/.config/nvim/

# Delete old files
rm -fr ~/.config/nvim

# Link dirs
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/nvim/ ~/.config/

# rm -fr ~/.gitconfig
# rm -fr ~/.tmux.conf

# link
# ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
# ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
