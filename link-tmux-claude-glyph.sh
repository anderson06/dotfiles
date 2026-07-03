rm -f ~/.local/bin/tmux-claude-glyph
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p ~/.local/bin
ln -sv $DOTFILES_DIR/tmux-claude-glyph.sh ~/.local/bin/tmux-claude-glyph
chmod +x $DOTFILES_DIR/tmux-claude-glyph.sh
