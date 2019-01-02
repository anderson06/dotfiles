call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree'

call plug#end()

" Mappings
let mapleader = "\<Space>"
nmap <leader>ne :NERDTreeToggle<cr>
imap jj <Esc>

" Copy current path to clipboard
nmap <leader>cp :let @+=expand("%")<CR>
