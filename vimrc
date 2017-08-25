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
Plug 'kien/ctrlp.vim'

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

" manage buffer
Plug 'jeetsukumaran/vim-buffergator'

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

" Git magic
Plug 'tpope/vim-fugitive'

call plug#end()

" Use 256 colours
set t_Co=256

" color scheme
syntax on
colorscheme dracula

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
set clipboard=unnamed

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

" Espaço + char para adicionar apenas um caracter no modo normal
nnoremap <Space> i_<Esc>r

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

" --------------------------------------
" vim-airline
" --------------------------------------
"
 " Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

" Add powerline fonts
let g:airline_powerline_fonts = 1

" buffer shortcuts

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
" CtrlP
" --------------------------------------

" habilita arquivos ocutos na busca do ctrlp
let g:ctrlp_show_hidden=1

" disable ctrlp's feature where it tries to intelligently work out the current working directory to search within
let g:ctrlp_working_path_mode=0

" não permite que o ctrlp tome toda a tela
let g:ctrlp_max_height=30

" Setup some default ignores
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
  \ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg)$',
\}

" Use the nearest .git directory as the cwd
" This makes a lot of sense if you are working on a project that is in version
" control. It also supports works with .svn, .hg, .bzr.
let g:ctrlp_working_path_mode = 'r'

" Use a leader instead of the actual named binding
nmap <leader>p :CtrlP<cr>

" Easy bindings for its various modes
nmap <leader>bb :CtrlPBuffer<cr>
nmap <leader>bm :CtrlPMixed<cr>
nmap <leader>bs :CtrlPMRU<cr>

" --------------------------------------
" Silver Searcher
" --------------------------------------

if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" --------------------------------------
" ack.vim
" --------------------------------------

if executable('ag')
  let g:ackprg = 'ag --column'
endif

nnoremap \ :Ack<SPACE>

" bind K to search word under cursor
nnoremap K :Ack <cword><cr>

