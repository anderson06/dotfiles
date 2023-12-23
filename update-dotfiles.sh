# Setup neovim
# rm -fr ~/.config/nvim
mv ~/.config/nvim ~/nvim_backup
mkdir -p ~/.config/nvim/
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/nvim/ ~/.config/nvim/

# rm -fr ~/.gitconfig
# rm -fr ~/.tmux.conf

# link
# ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
# ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
