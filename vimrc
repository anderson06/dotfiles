" --------------------------------------
" vim-plug
" --------------------------------------

" lista de plugins
call plug#begin('~/.vim/plugged')

" syntax highlighting melhorada para javascript
Plug 'pangloss/vim-javascript'

" syntax highligting jsx
Plug 'mxw/vim-jsx'

" navegar pela estrutura de arquivos
Plug 'scrooloose/nerdtree'

" carregar automaticamente configurações do editorconfig
Plug 'editorconfig/editorconfig-vim'

" syntax highlighting para o jade
Plug 'digitaltoad/vim-pug'

" para trabalhar com arquivos markdown
Plug 'tpope/vim-markdown'

" allows us to comment/uncomment lines and content
Plug 'tpope/vim-commentary'

" highlighting para identação
Plug 'nathanaelkane/vim-indent-guides'

" fuzy file finder
" Plug 'kien/ctrlp.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" quoting/parenthesizing made simple
Plug 'tpope/vim-surround'

" insert or delete brackets, parens, quotes in pair
Plug 'jiangmiao/auto-pairs'

" handy mappings
Plug 'tpope/vim-unimpaired'

" enable repeating supported plugin maps with '.'
Plug 'tpope/vim-repeat'

" status/tabline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" tmux/vim navigation
Plug 'christoomey/vim-tmux-navigator'

" less syntax highlighting
Plug 'groenewege/vim-less'

" mustache/handlebars syntax highlighting
Plug 'mustache/vim-mustache-handlebars'

" Run your favorite search tool from Vim, with an enhanced results list.
Plug 'mileszs/ack.vim'

" Colors
Plug 'dracula/vim'
Plug 'junegunn/seoul256.vim'
Plug 'chriskempson/base16-vim'
Plug 'morhetz/gruvbox'

" Git magic
Plug 'tpope/vim-fugitive'

" Better handling of tabs
Plug 'tpope/vim-sleuth'

" Add nice icons to nerd tree and other apps
Plug 'ryanoasis/vim-devicons'

" Tern - awesome js tools
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }

" syntatic checker
Plug 'w0rp/ale'

" indicates git changes in the gutter
Plug 'airblade/vim-gitgutter'

" it makes vim focus events works with tmux autoread
Plug 'tmux-plugins/vim-tmux-focus-events'

call plug#end()

" Use 256 colours
set t_Co=256

" color scheme
syntax on
colorscheme gruvbox
set background=dark

" Hightlight current line and column
set cursorline
set cursorcolumn

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" habilita o mouse
set mouse=a

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis
endif

" usa o clipboard do sistema para copiar e colar no vim
set clipboard=unnamedplus

" habilita syntax highlighting do jsx dentro de arquivos js
let g:jsx_ext_required = 0

" Permite mover o cursor sobre locais vazios
set virtualedit=all

" Permite sair buffers não salvos
set hidden

" Caracter inicial para todos os meus atalhos
" let mapleader = ","
let mapleader = "\<Space>"

" Atalho para abrir e fechar o plugin NERDTree
nmap <leader>ne :NERDTreeToggle<cr>

" Mapeia o esc do modo de inserção para jj
imap jj <Esc>

" copy current path to clipboard
nmap <leader>cp :let @+=expand("%:p")<CR>

" habilita a sintaxe colorida quando o terminal pode exibir cores
syntax on

" use o vim, não a api do vi
set nocompatible

" sem arquivos de backup
set nobackup

" sem backup de escrita
set nowritebackup

" disable swapfiles
set noswapfile

" histórico de comandos
set history=100

" sempre mostre o cursor
set ruler

" exibe comandos incompletos
set showcmd

" busca incremental
set incsearch

" ilumina busca
set hlsearch

" ignora maiúsculas na busca
set smartcase

" mapeia limpeza da busca
:nnoremap § :nohlsearch<cr>

" certifica de que o histórico do undo não apareça para arquivos no buffer
set hidden

" habilita identação
filetype indent on

" habilita plugins por tipo de arquivo
filetype plugin on

" disable folding because it is evil
set nofoldenable

" desabilita wordwrapp
set nowrap

" scroll com mais contexto
set scrolloff=10

" permite usar o backspace deletar eol, identação e caracter de início de
" linha
set backspace=indent,eol,start

" converte tabs em espaços
set expandtab

" configura o tamanho do tab
set tabstop=2

" quantidade de espaços por tab
set shiftwidth=2

" exibe o número da linha
set number

" highlight tailing whitespace
set list listchars=tab:\ \ ,trail:·

" get rid of the delay when pressing O (for example)
" http://stackoverflow.com/questions/2158516/vim-delay-before-o-opens-a-new-line
set timeout timeoutlen=1000 ttimeoutlen=100

" sempre exibir a barra de status
set laststatus=2

" barra de status mais útil
set statusline=%f\ %=L:%l/%L\ %c\ (%p%%)

" esconde a toolbar
set guioptions-=T

" utf encoding
set encoding=utf-8

" recarrega automaticamente arquivos que foram editados fora do vim
set autoread

" Show the 100th char column
set colorcolumn=100

" pula para a ultima posição do cursor
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

" não exibir estes arquivos
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*.,*/.DS_Store

" remove espaço branco ao salvar
autocmd BufWritePre * :%s/\s\+$//e

" navegação entre janelas
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" after a re-source, fix syntax matching issues (concealing brackets):
if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

" remove o highlight da última busca
nnoremap <CR> :noh<CR><CR>

" pula para o último buffer editado com backspace
nnoremap <bs> <c-^>

" fzf maps
map <leader>pb :Buffers<cr>
map <leader>pf :Files<cr>
map <leader>pg :GFiles<cr>
map <leader>pt :Tags<cr>

" --------------------------------------
" buffer shortcuts
" --------------------------------------

" To open a new empty buffer
nmap <leader>T :enew<cr>

" Move to the next buffer
nmap <leader>l :bnext<CR>

" Move to the previous buffer
nmap <leader>h :bprevious<CR>

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bq :bp <BAR> bd #<CR>

" Show all open buffers and their status
nmap <leader>bl :ls<CR>

" --------------------------------------
" vim-airline
" --------------------------------------

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

" bind K to search word under cursor
"nnoremap K :Ack <cword><cr>

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
