# clean
rm -fr ~/.gitconfig
rm -fr ~/.tmux.conf
rm -fr ~/.vimrc
rm -fr ~/.tern-config
rm -fr ~/.vim/after/plugin/after-load.vim

# create dirs
mkdir -p ~/.vim/after/plugin/

# link
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
ln -sv $DOTFILES_DIR/vimrc ~/.vimrc
ln -sv $DOTFILES_DIR/tern-config ~/.tern-config
ln -sv $DOTFILES_DIR/after-load.vim ~/.vim/after/plugin/after-load.vim
