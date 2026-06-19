rm -f ~/.local/bin/claude-dash
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p ~/.local/bin
ln -sv $DOTFILES_DIR/claude-dash.js ~/.local/bin/claude-dash
chmod +x $DOTFILES_DIR/claude-dash.js
