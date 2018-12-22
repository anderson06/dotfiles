#!/bin/bash

sh ./install-vim.sh

# install favorite terminal apps
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install fonts-firacode zsh tmux silversearcher-ag dconf-cli build-essential cmake python-dev python3-dev xclip

sh ./update-dotfiles.sh

# install vim-icons fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

# install vim-airline plugin required font
mkdir -p ~/.fonts
cd ~/.fonts
curl -fLo "Ubuntu Mono derivative Powerline.ttf" https://github.com/powerline/fonts/raw/master/UbuntuMono/Ubuntu%20Mono%20derivative%20Powerline.ttf
fc-cache -vf ~/.fonts/
cd ~

# Select gnome-terminal fonts
# TODO: make it work
# gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string "Ubuntu Mono derivative Powerline 13"
# gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_system_font --type=boolean false

# install vim plugin manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install vim plugins
vim -c "PlugInstall|qa"

# install oh-my-zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s `which zsh`

# use Gogh to set up Gruvbox Dark colors on gnome terminal
# https://github.com/Mayccoll/Gogh
wget -O xt https://git.io/v7eBS && chmod +x xt && ./xt && rm xt
