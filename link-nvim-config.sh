# Link /nvim/ to ~/.config/nvim/

# Create a backup of old configs
# mv ~/.config/nvim ~/nvim_backup

# Delete old files
rm -fr ~/.config/nvim

# Create dir if necessary
mkdir -p ~/.config/nvim/

# Link dirs
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/nvim/ ~/.config/

# rm -fr ~/.gitconfig
# rm -fr ~/.tmux.conf

# link
# ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
# ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
