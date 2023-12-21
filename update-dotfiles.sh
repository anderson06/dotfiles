# clean
# rm -fr ~/.gitconfig
# rm -fr ~/.tmux.conf
# rm -fr ~/.vimrc
# rm -fr ~/.vim/after/plugin/after-load.vim
rm -fr ~/.config/nvim/init.lua

# create dirs
# mkdir -p ~/.vim/after/plugin/
mkdir -p ~/.config/nvim/
# mkdir -p ~/.local/share/nvim/backup

# link
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
# ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
# ln -sv $DOTFILES_DIR/vimrc ~/.vimrc
# ln -sv $DOTFILES_DIR/after-load.vim ~/.vim/after/plugin/after-load.vim
ln -sv $DOTFILES_DIR/init.lua ~/.config/nvim/init.lua
