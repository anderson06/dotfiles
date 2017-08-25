# clean
rm -fr ~/.gitconfig
rm -fr ~/.tmux.conf
rm -fr ~/.vimrc

# link
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
ln -sv $DOTFILES_DIR/vimrc ~/.vimrc

# install vim plugin manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# update
sudo apt-get update

# install favorite terminal apps
sudo apt-get install zsh tmux vim-gnome

# install oh-my-zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s `which zsh`

