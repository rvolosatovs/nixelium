" ~~~ Vim configurations ~~~
filetype plugin indent on

"set modeline

set mouse=a
set termguicolors
set guicursor=

set undofile

set updatetime=250

set visualbell

set rtp^=/usr/share/vim/vimfiles
set rtp+=$GOPATH/src/github.com/golang/lint/misc/vim
set rtp+=$GOPATH/src/github.com/junegunn/fzf

" Buffers
set hidden

" Folding
" set foldmethod=syntax
set foldnestmax=1
set foldcolumn=1
set nofoldenable
"set foldlevel=2

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

set grepprg=rg\ --vimgrep
set grepformat^=%f:%l:%c:%m

set autochdir
"set tags=tags,./tags;

" ~~~ Plugins ~~~

call plug#begin('~/.local/share/nvim/plugins')

" Sanity check
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif

" Looks
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
Plug 'ryanoasis/vim-devicons'

" Code
Plug 'editorconfig/editorconfig-vim'
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'benekastah/neomake'
"Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'godlygeek/tabular'
Plug 'Chiel92/vim-autoformat'

" Steroids
Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'tpope/vim-repeat'
Plug 'junegunn/fzf.vim'

" Utility
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
Plug 'majutsushi/tagbar'
"Plug 'scrooloose/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-vinegar'
Plug 'sjl/gundo.vim'
Plug 'maxbrunsfeld/vim-yankstack'
"Plug 'vim-scripts/YankRing.vim'
"Plug 'vim-scripts/scratch.vim'
"Plug 'vim-scripts/FastFold'
Plug 'xolox/vim-misc'
"Plug 'xolox/vim-easytags'
"Plug 'xolox/vim-session'
"Plug 'kopischke/vim-stay'
Plug 'gregsexton/gitv'
Plug 'jiangmiao/auto-pairs'
"Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-unimpaired'
Plug 'terryma/vim-multiple-cursors'
Plug 'dhruvasagar/vim-table-mode'
Plug 'rkitover/vimpager'

" C
Plug 'Rip-Rip/clang_complete', { 'for': 'c' }
" Latex
Plug 'vim-latex/vim-latex', { 'for': 'tex' }
" Javascript
Plug 'ternjs/tern_for_vim', { 'for': 'javascript', 'do': 'npm install' }
Plug 'carlitux/deoplete-ternjs', {'for': 'javascript'}
Plug 'jason0x43/vim-js-indent', {'for': 'javascript'}
" Typescript
Plug 'leafgarland/typescript-vim', {'for': 'typescript'}
Plug 'Quramy/tsuquyomi', {'for': 'typescript'}
Plug 'Shougo/vimproc.vim', { 'for': 'typescript', 'build' : 'make'} " tsuquyomi dep
" Rust
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
" Go
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'zchee/deoplete-go', { 'for': 'go', 'do': 'make'}
" Arduino
Plug 'sudar/vim-arduino-syntax', { 'for': 'arduino' }
" Proto
Plug 'rvolosatovs/vim-protobuf', { 'for': 'proto' }
" Vim
Plug 'Shougo/neco-vim', { 'for': 'vim' }
" Sxhkd
Plug 'baskerville/vim-sxhkdrc', { 'for': 'sxhkdrc' }
" Rtorrent
Plug 'ccarpita/rtorrent-syntax-file', { 'for': 'rtorrent' }
" Julia
Plug 'JuliaEditorSupport/julia-vim'
Plug 'JuliaEditorSupport/deoplete-julia', { 'for': 'julia' }
" Nix
Plug 'LnL7/vim-nix', { 'for': 'nix' }
" GLSL
Plug 'tikhomirov/vim-glsl'

call plug#end()


" ~~~ Eye-candy ~~~

" Colorscheme
if $TERM!="linux"
    let base16colorspace=256
endif
set t_Co=256

color base16-tomorrow-night
set background=dark
"color seoul256
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

" Easytags
let g:easytags_file='~/.local/share/nvim/tags'
let g:easytags_by_filetype = '~/.local/share/nvim/tags'
let g:easytags_on_cursorhold= 0
"let g:easytags_auto_update = 1
"let g:easytags_async = 1

" EditorConfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" AutoPairs
let g:AutoPairsFlyMode = 0
let g:AutoPairsShortcutToggle = '<C-P>'

" YankRing
"let g:yankring_history_dir = \"$HOME/.local/share/nvim"
"let g:yankring_history_file = 'yankhist'
"let g:yankring_clipboard_monitor=0

" YankStack
call yankstack#setup()

" Deoplete
let g:deoplete#enable_at_startup = 1

" call deoplete#custom#set('_', 'disabled_syntaxes', ['Comment', 'String'])
" au VimEnter call deoplete#initialize()


" Tern
let g:tern_request_timeout = 1

" Vim-session
let g:session_autosave="no"
let g:session_autoload="no"

" Neomake
let g:neomake_open_list=1

" Gundo
let g:gundo_right=1
let g:gundo_preview_bottom=1

" FastFold
"let g:fastfold_savehook = 0

set viewoptions=cursor,slash,unix

" ~~~ Controls ~~~

" Essential
nnoremap      ;  :
nnoremap <SPACE>  <Nop>
let mapleader = "\<Space>"

" Insert-mode
inoremap      jk  <Esc>
inoremap      kj  <Esc>

" Fix yank
noremap Y y$

noremap K i<CR><Esc>
noremap H 0
noremap L $

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

nmap <Leader>ln   :lnext<CR>
nmap <Leader>lN   :lNext<CR>
nmap <Leader>ll   :ll<CR>
nmap <Leader>cn   :cnext<CR>
nmap <Leader>cN   :cNext<CR>
nmap <Leader>cc   :cc<CR>
"nmap <Leader>m    :make<CR>

" New
nmap <Leader>ze   :enew <CR>
nmap <Leader>zt   :tabnew<CR>

" Toggles
nmap <Leader>tO   :e .<CR>
nmap <Leader>to   :e %:p:h<CR>
"nmap <Leader>tn   :NERDTreeToggle<CR>
nmap <Leader>tt   :TagbarToggle<CR>
nmap <Leader>tu   :GundoToggle<CR>
nmap <Leader>tp   :Yanks<CR>
"nmap <Leader>ts   :Sscratch<CR>
"nmap <Leader>tS   :Scratch<CR>

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
nmap <Leader>O    :GFiles <CR>
nmap <Leader>fl   :BLines <CR>
nmap <Leader>fL   :Lines <CR>
nmap <Leader>fh   :History<CR>
nmap <Leader>f;   :History:<CR>
nmap <Leader>f:   :Commands<CR>
nmap <Leader>ft   :BTags<CR>
nmap <Leader>fT   :Tags<CR>
nmap <Leader>fm   :Marks<CR>
nmap <Leader>fw   :Windows<CR>
nmap <Leader>fs   :Snippets<CR>
nmap <Leader>fg   :BCommits<CR>
nmap <Leader>fG   :Commits<CR>

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" Incsearch
let g:incsearch#auto_nohlsearch = 1
nnoremap           /   <Plug>(incsearch-easymotion-/)
nnoremap           ?   <Plug>(incsearch-easymotion-?)
nnoremap           g/  <Plug>(incsearch-easymotion-stay)
nnoremap           *   <Plug>(incsearch-nohl-*)
nnoremap           n   <Plug>(incsearch-nohl-n)
nnoremap           N   <Plug>(incsearch-nohl-N)
nnoremap           #   <Plug>(incsearch-nohl-#)
nnoremap           g*  <Plug>(incsearch-nohl-g*)
nnoremap           g#  <Plug>(incsearch-nohl-g#)

" EasyMotion
let g:EasyMotion_keys='hjkluiobnmxcvwersdfg'
let g:EasyMotion_startofline = 0
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_smartcase = 1

nnoremap            f  <Plug>(easymotion-f)
nnoremap            F  <Plug>(easymotion-F)
nnoremap            t  <Plug>(easymotion-t)
nnoremap            T  <Plug>(easymotion-T)
nnoremap            s  <Plug>(easymotion-s2)
nnoremap            S  <Plug>(easymotion-overwin-f2)
nnoremap    <Leader>w  <Plug>(easymotion-w)
nnoremap    <Leader>W  <Plug>(easymotion-W)
nnoremap    <Leader>b  <Plug>(easymotion-b)
nnoremap    <Leader>B  <Plug>(easymotion-B)
nnoremap    <Leader>e  <Plug>(easymotion-e)
nnoremap    <Leader>E  <Plug>(easymotion-E)
nnoremap    <Leader>ge <Plug>(easymotion-ge)
nnoremap    <Leader>gE <Plug>(easymotion-gE)

nnoremap    <Leader>gl <Plug>(easymotion-overwin-line)

nnoremap    <Leader>gn <Plug>(easymotion-next)
nnoremap    <Leader>gN <Plug>(easymotion-prev)
nnoremap    <Leader>n  <Plug>(easymotion-vim-n)
nnoremap    <Leader>N  <Plug>(easymotion-vim-N)

"map    <Leader>h  <Plug>(easymotion-linebackward)
nnoremap    <Leader>j  <Plug>(easymotion-j)
nnoremap    <Leader>k  <Plug>(easymotion-k)
"map    <Leader>l  <Plug>(easymotion-lineforward)

" UltiSnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsListSnippets="<leader><tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

nmap <Leader>m :Neomake<CR>

" ~~~ Autocmd ~~~

" Filetype-specific keybinds(TODO:migrate to /ft)
au FileType sh         inoremap <buffer> ## <Esc>79i#<Esc>yypO#<Space>
au FileType conf       inoremap <buffer> ## <Esc>79i#<Esc>yypO#<Space>

" Layout
"au vimenter * if argc() == 0 | NERDTree | wincmd l | endif
"au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Func
au FocusLost * :wa

" Filetype-specific settings
"au FileType html setlocal foldmethod=indent
au FileType typescript setlocal noexpandtab
