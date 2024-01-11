# Link /nvim/ to ~/.config/nvim/

# Delete old files
rm -fr ~/.config/nvim

# Link dirs
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/nvim/ ~/.config/
