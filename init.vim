call plug#begin('~/.local/share/nvim/plugged')

" Tree explorer plugin
Plug 'scrooloose/nerdtree'

" Nice icons
Plug 'ryanoasis/vim-devicons'

" Colors
Plug 'dracula/vim'
Plug 'junegunn/seoul256.vim'
Plug 'chriskempson/base16-vim'
Plug 'morhetz/gruvbox'

" Load editor seetings by project when available
Plug 'editorconfig/editorconfig-vim'

" Easily comment
Plug 'tpope/vim-commentary'

" File finder (I love this plugin <3)
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-surround'

" Auto complete parentheses
Plug 'jiangmiao/auto-pairs'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Fix tabulation forever
Plug 'tpope/vim-sleuth'

Plug 'w0rp/ale'

" It makes vim focus events works with tmux autoread
Plug 'tmux-plugins/vim-tmux-focus-events'

Plug 'terryma/vim-multiple-cursors'
Plug 'sheerun/vim-polyglot'
Plug 'mileszs/ack.vim'

" Handy mappings
Plug 'tpope/vim-unimpaired'

" Enable repeating supported plugin maps with '.'
Plug 'tpope/vim-repeat'

" Async autocomplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Snipets
Plug 'SirVer/ultisnips'

" Snipets engines
Plug 'honza/vim-snippets'

call plug#end()

" Configuration

" Enable to exit unsaved files
set hidden

set number
set relativenumber
set mouse=a
set inccommand=split

" Set colorscheme preferenses
colorscheme gruvbox
set background=dark

" enable trasnparent background
hi Normal guibg=NONE ctermbg=NONE

" set cursorline
" set cursorcolumn

set clipboard=unnamedplus
set virtualedit=all

" Gives some space when scroll to top or bottom
set scrolloff=5

" Mappings
let mapleader = "\<Space>"
nmap <leader>ne :NERDTreeToggle<cr>
inoremap jj <esc>
nnoremap <leader>; A;<esc>
nnoremap <leader>ev :vsplit ~/.config/nvim/init.vim<cr>
nnoremap <leader>sv :source ~/.config/nvim/init.vim<cr>
nmap <leader>cp :let @+=expand("%")<cr>
nnoremap <cr> :noh<cr>
nnoremap <bs> <c-^>
map <leader>pb :Buffers<cr>
map <leader>pf :Files<cr>
map <leader>pg :GFiles<cr>
map <leader>pt :Tags<cr>
nmap <leader>T :enew<cr>
nmap <leader>l :bnext<cr>
nmap <leader>h :bprevious<cr>
nmap <leader>bq :bp <BAR> bd #<cr>
nmap <leader>bl :ls<cr>
nnoremap <c-p> :Files<cr>
nnoremap <c-g> :GFiles<cr>
nnoremap <c-f> :Ag<space>

" fix slow navigation on ruby files
" https://stackoverflow.com/questions/16902317/vim-slow-with-ruby-syntax-highlighting
set re=1

" vim-airline

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" Add powerline fonts
let g:airline_powerline_fonts = 1

" --------------------------------------
" Silver Searcher
" --------------------------------------

if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " use it in ack.vim
  let g:ackprg = 'ag --column'
endif

" --------------------------------------
" ack.vim
" --------------------------------------
nnoremap \ :Ack<SPACE>

" --------------------------------------
" devfonts
" --------------------------------------

" These are the basic settings to get the font to work (required):
set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ Complete\ 12

" --------------------------------------
" git gutter
" --------------------------------------

" toggle signs faster
imap <c-x><c-o> <plug>(fzf-complete-line)
set updatetime=250

" remap shortcuts
nmap <Leader>gs <Plug>GitGutterStageHunk
nmap <Leader>gu <Plug>GitGutterUndoHunk
nmap <Leader>gp <Plug>GitGutterPreviewHunk

" --------------------------------------
" vim behavior
" --------------------------------------

" triggers autoread whenever I switch buffer or when focusing
au FocusGained,BufEnter * :silent! !

" deoplete configs

let g:deoplete#enable_at_startup = 1

" --------------------------------------
" Snipets configs
" --------------------------------------

" Trigger configuration
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetsDir="~/.configs/nvim/UltiSnips"

nmap <Leader>use :UltiSnipsEdit<cr>
