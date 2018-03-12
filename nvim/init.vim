" ~~~ Plugins ~~~
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

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

"Plug 'majutsushi/tagbar'
"Plug 'tpope/vim-vinegar' "( https://github.com/tpope/vim-vinegar/issues/87 )
Plug 'Chiel92/vim-autoformat'
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'Shougo/neoinclude.vim'
Plug 'Shougo/neosnippet.vim'
Plug 'benekastah/neomake'
Plug 'dhruvasagar/vim-table-mode'
Plug 'godlygeek/tabular'
Plug 'gregsexton/gitv'
Plug 'haya14busa/incsearch.vim'
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-dirvish'
Plug 'ludovicchabant/vim-gutentags'
Plug 'mhinz/vim-signify'
Plug 'raghur/vim-ghost', {'do': ':GhostInstall'}
Plug 'scrooloose/nerdcommenter'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/incsearch-easymotion.vim'

Plug 'editorconfig/editorconfig-vim'

Plug 'Shougo/vimproc.vim', {'do' : 'make'}

Plug 'Quramy/tsuquyomi', {'for': 'typescript'}
"Plug 'carlitux/deoplete-ternjs', {'for': 'javascript', 'do': 'npm install -g tern'}
"Plug 'ternjs/tern_for_vim', { 'for': 'javascript', 'do': 'npm install' }
Plug 'JuliaEditorSupport/deoplete-julia', { 'for': 'julia' }
Plug 'Shougo/neco-vim', { 'for': 'vim' }
Plug 'ccarpita/rtorrent-syntax-file', { 'for': 'rtorrent' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'lervag/vimtex', { 'for': 'tex' }
Plug 'vhda/verilog_systemverilog.vim'
Plug 'zchee/deoplete-clang', { 'for': 'c,cpp,objc' }
Plug 'zchee/deoplete-go', { 'for': 'go', 'do': 'make'}
Plug 'parsonsmatt/intero-neovim', { 'for': 'haskell' }
Plug 'eagletmt/neco-ghc', { 'for': 'haskell' }
Plug 'eagletmt/ghcmod-vim', { 'for': 'haskell' }
Plug 'alx741/vim-hindent', { 'for': 'haskell' }
Plug 'alx741/vim-stylishask', { 'for': 'haskell' }
Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java' }
Plug 'hsanson/vim-android', { 'for': 'java' }

Plug 'sheerun/vim-polyglot'

call plug#end()

runtime macros/matchit.vim

let g:polyglot_disabled = ['go' , 'latex']

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
"set foldnestmax=20
"set foldenable
set foldcolumn=1
set foldlevel=20
set foldlevelstart=7
set foldmethod=syntax
set foldignore=""
set nofoldenable

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
set autoindent

" The encoding displayed.
set encoding=utf-8

" The encoding written to file.
set fileencoding=utf-8

" Line endings
set fileformat=unix

" Completion
if has('nvim')
    set completeopt+=menu,menuone
endif

" Set terminal title
set title

set grepprg=rg\ --vimgrep
set grepformat^=%f:%l:%c:%m

"set autochdir
"set tags=tags,./tags;

set viewoptions=cursor,slash,unix


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

" Called once right before you start selecting multiple cursors
function! Multiple_cursors_before()
    if exists('g:deoplete#disable_auto_complete')
        let g:deoplete#disable_auto_complete = 1
    endif
endfunction

" Called once only when the multiple selection is canceled (default <Esc>)
function! Multiple_cursors_after()
    if exists('g:deoplete#disable_auto_complete')
        let g:deoplete#disable_auto_complete = 0
    endif
endfunction

let g:multi_cursor_exit_from_visual_mode = 0
let g:multi_cursor_exit_from_insert_mode = 0

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
"call yankstack#setup()

" Deoplete
let g:deoplete#enable_at_startup = 1

" call deoplete#custom#set('_', 'disabled_syntaxes', ['Comment', 'String'])
" au VimEnter call deoplete#initialize()

" Clang
let g:deoplete#sources#clang#libclang_path="/home/rvolosatovs/.nix-profile/lib/libclang.so"
let g:deoplete#sources#clang#clang_header="/home/rvolosatovs/.nix-profile/lib/clang"

" JSX
let g:jsx_ext_required = 0

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

" ~~~ Controls ~~~

" Essential
noremap         ;  :
"noremap        ;;  ; 
noremap        ;;  <Plug>(easymotion-next)
noremap        ,   <Plug>(easymotion-prev)
nnoremap <SPACE>  <Nop>
let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

" Insert-mode
inoremap      jk  <Esc>
inoremap      kj  <Esc>

" Fix yank
noremap Y y$

noremap K i<CR><Esc>
noremap H 0
noremap L $

" Navigation
"nnoremap      j   gj
"nnoremap      k   gk
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Vim-related
nmap <Leader>vw   :w<CR>
nmap <Leader>vW   :wa<CR>
nmap <Leader>vq   :wqall<CR>
nmap <Leader>vQ   :qa<CR>
nmap <Leader>ve   :e ~/.config/nvim/init.vim<CR>
nmap <Leader>vr   :source ~/.config/nvim/init.vim<CR>
nmap <Leader>vP   :PlugInstall<CR>
nmap <Leader>vp   :PlugUpdate<CR>

"nmap <Leader>ln   :lnext<CR>
"nmap <Leader>lN   :lNext<CR>
"nmap <Leader>ll   :ll<CR>
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
"nmap <Leader>ss   :SaveSession<CR>
"nmap <Leader>sS   :SaveSession
"nmap <Leader>so   :OpenSession<CR>
"nmap <Leader>sO   :OpenSession

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
map           /   <Plug>(incsearch-easymotion-/)
map           ?   <Plug>(incsearch-easymotion-?)
map           g/  <Plug>(incsearch-easymotion-stay)
"map           /   <Plug>(incsearch-forward)
"map           ?   <Plug>(incsearch-backward)
"map           g/  <Plug>(incsearch-stay)
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
"
"map    <Leader>gl <Plug>(easymotion-overwin-line)
"
"map    <Leader>gn <Plug>(easymotion-next)
"map    <Leader>gN <Plug>(easymotion-prev)
map    <Leader>n  <Plug>(easymotion-vim-n)
map    <Leader>N  <Plug>(easymotion-vim-N)
"
""map    <Leader>h  <Plug>(easymotion-linebackward)
map    <Leader>j  <Plug>(easymotion-j)
map    <Leader>k  <Plug>(easymotion-k)
""map    <Leader>l  <Plug>(easymotion-lineforward)

" UltiSnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsListSnippets="<leader><tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Neosnippet
let g:neosnippet#disable_runtime_snippets = { "_": 1, }
"let g:neosnippet#snippets_directory='~/.local/share/nvim/plugins/vim-snippets/snippets'

" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
    set conceallevel=2 concealcursor=nc
endif

let g:tex_conceal="ag"
let g:vimtex_view_method='zathura'

nmap <localleader>ll <plug>(vimtex-compile-ss)

nmap <Leader>m :Neomake<CR>

"let g:sneak#s_next = 1
"let g:sneak#use_ic_scs = 1
"let g:sneak#label = 1
"let g:sneak#target_labels = 'hjkluiobnmxcvwersdfg'
"autocmd ColorScheme * hi Sneak guifg=black guibg=red ctermfg=black ctermbg=red
"autocmd ColorScheme * hi SneakScope guifg=red guibg=yellow ctermfg=red ctermbg=yellow


" ~~~ Autocmd ~~~

" Filetype-specific keybinds(TODO:migrate to /ft)
au FileType sh         inoremap <buffer> ## <Esc>79i#<Esc>yypO#<Space>
au FileType conf       inoremap <buffer> ## <Esc>79i#<Esc>yypO#<Space>

au FileType dirvish call fugitive#detect(@%)

" Layout
"au vimenter * if argc() == 0 | NERDTree | wincmd l | endif
"au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Func
au FocusLost * :wa

" Filetype-specific settings
"au FileType html setlocal foldmethod=indent
au FileType typescript setlocal noexpandtab
au FileType verilog_systemverilog set makeprg=verilator\ --lint-only\ %
au FileType verilog_systemverilog VerilogErrorFormat verilator 2
