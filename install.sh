# clean
rm -fr ~/.gitconfig
rm -fr ~/.tmux.conf
rm -fr ~/.vimrc

# link
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sv $DOTFILES_DIR/gitconfig ~/.gitconfig
ln -sv $DOTFILES_DIR/tmux.conf ~/.tmux.conf
ln -sv $DOTFILES_DIR/vimrc ~/.vimrc

# install fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
