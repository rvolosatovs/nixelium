#! vim: set ft=vim
" ~~~ Vim configurations ~~~
filetype plugin indent on

" Buffers
set hidden

" Folding
set foldmethod=syntax
set foldnestmax=5
set foldcolumn=2
set foldlevel=2

" Searching
set wrapscan
set incsearch
set ignorecase
set smartcase
set gdefault

" Highlighting
set hlsearch

" Make navigation easier
set number
set relativenumber

" Usable 'Tab'
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

" Indentation
set smartindent

" Completion
if has('nvim')
    set completeopt+=menu,menuone
endif

" Set terminal title
set title

" ~~~ Plugins ~~~

call plug#begin('~/.local/share/nvim/plugins')

" Sanity check
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif

" Looks 
Plug 'chriskempson/base16-vim'
" Plug 'junegunn/seoul256.vim'
" Plug 'jnurmine/Zenburn'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
Plug 'ryanoasis/vim-devicons'

" Code
Plug 'Shougo/deoplete.nvim'
Plug 'benekastah/neomake'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'godlygeek/tabular'
Plug 'Chiel92/vim-autoformat'
Plug 'fatih/vim-go'
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'nsf/gocode', {'rtp': 'vim'}
" , { 'do': '~/.local/share/nvim/plugins/gocode/vim/symlink.sh' }

" Steroids
Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'tpope/vim-repeat'
Plug 'junegunn/fzf', { 'dir': '~/.local/fzf', 'do': './install --no-update-rc --no-key-bindings' }
Plug 'junegunn/fzf.vim'

" Filetype-related
Plug 'vim-latex/vim-latex'
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
Plug 'carlitux/deoplete-ternjs'
Plug 'jason0x43/vim-js-indent'
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/tsuquyomi'
Plug 'Shougo/vimproc.vim', { 'build' : 'make'} " tsuquyomi dep

" Utility
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'sjl/gundo.vim'
Plug 'vim-scripts/YankRing.vim'
Plug 'vim-scripts/scratch.vim'
Plug 'vim-scripts/FastFold'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
Plug 'kopischke/vim-stay'

call plug#end()



" ~~~ Eye-candy ~~~

" Colorscheme
if $TERM!="linux"
    let base16colorspace=256
endif
set t_Co=256

color base16-twilight
set background=dark
" color seoul256
" color zenburn

" Airline
let g:airline_powerline_fonts = 1
let g:airline_theme='base16'
let g:airline#extensions#bufferline#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1

let g:airline#extensions#tabline#tab_min_count = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#show_splits = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#tab_nr_type = 2

" Bufferline
let g:bufferline_echo = 0

" ~~~ Plugin configs ~~~

" YankRing
let g:yankring_history_dir = "$HOME/.local/share/nvim" 
let g:yankring_history_file = 'yankhist'

" TeX
let g:Tex_ViewRule_pdf = 'zathura'
let g:Tex_ViewRule_dvi = 'zathura'
let g:Tex_ViewRule_ps = 'zathura'
let g:Tex_CompileRule_pdf = 'pdflatex -interaction=nonstopmode $*'
let g:Tex_DefaultTargetFormat = 'pdf'

" Go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"

" Deoplete
let g:deoplete#enable_at_startup = 1
" call deoplete#custom#set('_', 'disabled_syntaxes', ['Comment', 'String'])
" au VimEnter call deoplete#initialize()
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

" Tern
let g:tern_request_timeout = 1

" Vim-session
let g:session_autosave="no"
let g:session_autoload="no"

" FastFold
let g:fastfold_savehook = 0

set viewoptions=cursor,folds,slash,unix

" ~~~ Controls ~~~

" Essential
nnoremap      ;  :
nnoremap <SPACE>  <Nop>
let mapleader = "\<Space>"

" Insert-mode
inoremap      jk  <Esc>
inoremap      kj  <Esc>

inoremap      '   ''<Esc>i
inoremap      "   ""<Esc>i
inoremap      (   ()<Esc>i
inoremap      [   []<Esc>i
inoremap      {   {}<Esc>i

inoremap (<Space>  ();<Esc>hi
inoremap      (;   ();<Esc>o
inoremap      ()   ()
inoremap    {<CR>  {<CR>}<Esc>O

" Navigation
nnoremap      j   gj
nnoremap      k   gk
nnoremap  <C-h>   <C-w>h
nnoremap  <C-j>   <C-w>j
nnoremap  <C-k>   <C-w>k
nnoremap  <C-l>   <C-w>l

" Vim-related
nmap <Leader>vw   :w<CR>
nmap <Leader>vW   :wa<CR>
nmap <Leader>vq   :wqall<CR>
nmap <Leader>vQ   :qa<CR>
nmap <Leader>ve   :e ~/.config/nvim/init.vim<CR>
nmap <Leader>vr   :source ~/.config/nvim/init.vim<CR>
nmap <Leader>vP   :PlugInstall<CR>
nmap <Leader>vp   :PlugUpdate<CR>
nmap <Leader>vm   :make<CR>

" Toggles
nmap <Leader>tT   :tabnew<CR>
nmap <Leader>tb   :enew <CR>
nmap <Leader>tO   :e .<CR>
nmap <Leader>to   :e %:p:h<CR>
nmap <Leader>tn   :NERDTreeToggle<CR>
nmap <Leader>tt   :TagbarToggle<CR>
nmap <Leader>tu   :GundoToggle<CR>
nmap <Leader>tp   :YRShow<CR>
nmap <Leader>ts   :Sscratch<CR>
nmap <Leader>tS   :Scratch<CR>

" Sessions
nmap <Leader>ss   :SaveSession<CR>
nmap <Leader>sS   :SaveSession
nmap <Leader>so   :OpenSession<CR>
nmap <Leader>sO   :OpenSession

" Buffer control
nmap <Leader>u    :bprevious<CR>
nmap <Leader>i    :bnext<CR>
nmap <Leader>qb   :bp<BAR> bd #<CR>

" Formatting
nmap <Leader>af   :Autoformat<CR>

" 'cd' to wd
nmap <Leader>cd   :cd %:p:h<CR>:pwd<CR>

" FZF
"command! -nargs= 1 Locate call fzf#run({'source': 'locate <q-args>', 'sink': 'e', 'options': '-m'})
nmap <Leader>fb   :Buffers <CR>
nmap <Leader>o    :Files %:p:h<CR>
nmap <Leader>O    :Files <CR>
nmap <Leader>ff   :BLines <CR>
nmap <Leader>fo   :Lines <CR>
nmap <Leader>fh   :History<CR>

" Incsearch
let g:incsearch#auto_nohlsearch = 1
map           /   <Plug>(incsearch-easymotion-/)
map           ?   <Plug>(incsearch-easymotion-?)
map           g/  <Plug>(incsearch-easymotion-stay)
map           *   <Plug>(incsearch-nohl-*)
map           n   <Plug>(incsearch-nohl-n)
map           N   <Plug>(incsearch-nohl-N)
map           #   <Plug>(incsearch-nohl-#)
map           g*  <Plug>(incsearch-nohl-g*)
map           g#  <Plug>(incsearch-nohl-g#)

" EasyMotion
let g:EasyMotion_keys='hjkluiobnmxcvwersdfg'
let g:EasyMotion_startofline = 0
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1

map            f  <Plug>(easymotion-f)
map            F  <Plug>(easymotion-F)
map            t  <Plug>(easymotion-t)
map            T  <Plug>(easymotion-T)
map            s  <Plug>(easymotion-s2)
map            S  <Plug>(easymotion-overwin-f2)
map    <Leader>w  <Plug>(easymotion-w)
map    <Leader>W  <Plug>(easymotion-W)
map    <Leader>b  <Plug>(easymotion-b)
map    <Leader>B  <Plug>(easymotion-B)
map    <Leader>e  <Plug>(easymotion-e)
map    <Leader>E  <Plug>(easymotion-E)
map    <Leader>ge <Plug>(easymotion-ge)
map    <Leader>gE <Plug>(easymotion-gE)

map    <Leader>gl <Plug>(easymotion-overwin-line)

map    <Leader>gn <Plug>(easymotion-next)
map    <Leader>gN <Plug>(easymotion-prev)
map    <Leader>n  <Plug>(easymotion-vim-n)

map    <Leader>h  <Plug>(easymotion-linebackward)
map    <Leader>j  <Plug>(easymotion-j)
map    <Leader>k  <Plug>(easymotion-k)
map    <Leader>l  <Plug>(easymotion-lineforward)

" UltiSnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" ~~~ Autocmd ~~~

" Filetype-specific keybinds(TODO:migrate to /ft)
au FileType typescript inoremap <buffer> <Space>: :<Space>,<Esc>i
au FileType typescript inoremap <buffer> : :<Space>
au FileType javascript inoremap <buffer> <Space>: :<Space>,<Esc>i
au FileType javascript inoremap <buffer> : :<Space>

au FileType sh         inoremap <buffer> ## <Esc>79i#<Esc>yypO#<Space>
au FileType conf       inoremap <buffer> ## <Esc>79i#<Esc>yypO#<Space>

au FileType vim        inoremap <buffer> "" "<Space>~~~<Space><Space>~~~<Esc>bhi
au FileType vim        inoremap <buffer> "  "<Space>

au FileType go             nmap <leader>er <Plug>(go-run)
au FileType go             nmap <leader>eb <Plug>(go-build)
au FileType go             nmap <leader>et <Plug>(go-test)
au FileType go             nmap <leader>ec <Plug>(go-coverage)

" Layout
au vimenter * if argc() == 0 | NERDTree | wincmd l | endif
au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Func
au FocusLost * :wa

" Filetype-specific settings
au FileType html setlocal foldmethod=indent
au FileType typescript setlocal noexpandtab
