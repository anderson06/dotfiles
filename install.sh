# clean
rm -fr ~/.gitconfig
rm -fr ~/.tmux.conf
rm -fr ~/.vimrc

# link
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
ln -sv $DOTFILES_DIR/vimrc ~/.vimrc

# install nerd fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

# install anonymous pro fonts
mkdir -p ~/.fonts
cd ~/.fonts
curl -fLo "Anonymice Powerline Bold Italic.ttf" https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice%20Powerline%20Bold%20Italic.ttf
curl -fLo "Anonymice Powerline Bold.ttf" https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice%20Powerline%20Bold.ttf
curl -fLo "Anonymice Powerline Italic.ttf" https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice%20Powerline%20Italic.ttf
curl -fLo "Anonymice Powerline.ttf" https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice%20Powerline.ttf
fc-cache -vf ~/.fonts/

# install vim plugin manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install vim plugins
vim -c "PlugInstall|qa"

# install favorite terminal apps
sudo apt-get update
sudo apt-get install zsh tmux vim-gnome silversearcher-ag

# install oh-my-zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s `which zsh`
