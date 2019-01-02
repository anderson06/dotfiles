# install favorite terminal apps
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install neovim fonts-firacode zsh tmux silversearcher-ag dconf-cli build-essential cmake python-dev python3-dev xclip

# install oh-my-zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s `which zsh`
