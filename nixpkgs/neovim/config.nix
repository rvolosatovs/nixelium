pkgs: ''
  autocmd FileType go :packadd vim-go
  let g:polyglot_disabled = [ 'go' ]

  if $TERM!="linux"
  let base16colorspace=256
  endif
  color base16-tomorrow-night
  set background=dark

  runtime macros/matchit.vim
  filetype plugin indent on

  set autoindent
  set completeopt+=menu,menuone
  set encoding=utf-8
  set expandtab
  set fileencoding=utf-8
  set fileformat=unix
  set foldcolumn=1
  set foldignore=""
  set foldlevel=20
  set foldlevelstart=7
  set foldmethod=syntax
  set foldnestmax=20
  set gdefault
  set grepformat^=%f:%l:%c:%m
  set grepprg=rg\ --vimgrep
  set guicursor=
  set hidden
  set hlsearch
  set ignorecase
  set incsearch
  set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>
  set mouse=a
  set nofoldenable
  set nrformats=alpha,octal,hex,bin
  set number
  set relativenumber
  set shiftwidth=4
  set smartcase
  set softtabstop=4
  set tabstop=4
  set termguicolors
  set title
  set undofile
  set updatetime=250
  set viewoptions=cursor,slash,unix
  set visualbell
  set wrapscan
  set t_Co=256

  let g:airline#extensions#branch#enabled = 1
  let g:airline#extensions#bufferline#enabled = 1
  let g:airline#extensions#syntastic#enabled = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#fnamemod = ':t'
  let g:airline#extensions#tabline#show_buffers = 0
  let g:airline#extensions#tabline#show_splits = 1
  let g:airline#extensions#tabline#tab_min_count = 1
  let g:airline#extensions#tabline#tab_nr_type = 2
  let g:airline#extensions#tagbar#enabled = 1
  let g:airline_powerline_fonts = 1
  let g:airline_theme='base16'

  let g:bufferline_echo = 0

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

  let g:easytags_file='~/.local/share/nvim/tags'
  let g:easytags_by_filetype = '~/.local/share/nvim/tags'
  let g:easytags_on_cursorhold= 0

  let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

  let g:AutoPairsFlyMode = 0
  let g:AutoPairsShortcutToggle = '<C-P>'

  let g:deoplete#enable_at_startup = 1

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
  noremap        ;;  ;
  "noremap        ;;  <Plug>(easymotion-next)
  "noremap        ,   <Plug>(easymotion-prev)
  nnoremap <SPACE>  <Nop>
  let mapleader = "\<Space>"
  let maplocalleader = "\<Space>"

  noremap Y y$

  noremap K i<CR><Esc>

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
  "map           /   <Plug>(incsearch-easymotion-/)
  "map           ?   <Plug>(incsearch-easymotion-?)
  "map           g/  <Plug>(incsearch-easymotion-stay)
  nmap           /   <Plug>(incsearch-forward)
  nmap           ?   <Plug>(incsearch-backward)
  nmap           g/  <Plug>(incsearch-stay)
  "nmap           *   <Plug>(incsearch-nohl-*)
  "nmap           n   <Plug>(incsearch-nohl-n)
  "nmap           N   <Plug>(incsearch-nohl-N)
  "nmap           #   <Plug>(incsearch-nohl-#)
  nmap           n   <Plug>(incsearch-nohl)<Plug>(anzu-n-with-echo)
  nmap           N   <Plug>(incsearch-nohl)<Plug>(anzu-N-with-echo)
  nmap           *   <Plug>(incsearch-nohl)<Plug>(anzu-star-with-echo)
  nmap           #   <Plug>(incsearch-nohl)<Plug>(anzu-sharp-with-echo)
  nmap           g*  <Plug>(incsearch-nohl-g*)<Plug>(anzu-update-search-status-with-echo)
  nmap           g#  <Plug>(incsearch-nohl-g#)<Plug>(anzu-update-search-status-with-echo)

  " EasyMotion
  let g:EasyMotion_keys='hjkluiobnmxcvwersdfg'
  let g:EasyMotion_startofline = 0
  let g:EasyMotion_do_mapping = 0
  let g:EasyMotion_smartcase = 1


  "nmap            f  <Plug>(easymotion-f)
  "nmap            F  <Plug>(easymotion-F)
  "nmap            t  <Plug>(easymotion-t)
  "nmap            T  <Plug>(easymotion-T)
  "nmap            s  <Plug>(easymotion-s2)
  "nmap            S  <Plug>(easymotion-overwin-f2)
  "nmap    <Leader>w  <Plug>(easymotion-w)
  "nmap    <Leader>W  <Plug>(easymotion-W)
  "nmap    <Leader>b  <Plug>(easymotion-b)
  "nmap    <Leader>B  <Plug>(easymotion-B)
  "nmap    <Leader>e  <Plug>(easymotion-e)
  "nmap    <Leader>E  <Plug>(easymotion-E)
  "nmap    <Leader>ge <Plug>(easymotion-ge)
  "nmap    <Leader>gE <Plug>(easymotion-gE)
  "
  "map    <Leader>gl <Plug>(easymotion-overwin-line)
  "
  "map    <Leader>gn <Plug>(easymotion-next)
  "map    <Leader>gN <Plug>(easymotion-prev)
  "nmap    <Leader>n  <Plug>(easymotion-vim-n)
  "nmap    <Leader>N  <Plug>(easymotion-vim-N)
  "
  ""map    <Leader>h  <Plug>(easymotion-linebackward)
  "nmap    <Leader>j  <Plug>(easymotion-j)
  "nmap    <Leader>k  <Plug>(easymotion-k)
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
  set conceallevel=0 concealcursor=nc
  endif

  let g:tex_conceal="ag"
  let g:vimtex_view_method='zathura'

  nmap <localleader>ll <plug>(vimtex-compile-ss)

  nmap <Leader>m :Neomake<CR>
  nmap <Leader>M :Neomake!<CR>

  "let g:sneak#s_next = 1
  "let g:sneak#use_ic_scs = 1
  "let g:sneak#label = 1
  "let g:sneak#target_labels = 'hjkluiobnmxcvwersdfg'
  "autocmd ColorScheme * hi Sneak guifg=black guibg=red ctermfg=black ctermbg=red
  "autocmd ColorScheme * hi SneakScope guifg=red guibg=yellow ctermfg=red ctermbg=yellow

  " Creates a session
  function! MakeSession()
  let b:sessiondir = $XDG_DATA_HOME . "/nvim/sessions" . getcwd()
  if (filewritable(b:sessiondir) != 2)
  exe 'silent !mkdir -p ' b:sessiondir
  redraw!
  endif
  let b:sessionfile = b:sessiondir . '/session.vim'
  exe "mksession! " . b:sessionfile
  echo "Created new session"
  endfunction

  function! UpdateSession()
  if argc() == 0
  let b:sessiondir = $XDG_DATA_HOME . "/nvim/sessions" . getcwd()
  let b:sessionfile = b:sessiondir . "/session.vim"
  if (filereadable(b:sessionfile))
  exe "mksession! " . b:sessionfile
  echo "updating session"
  endif
  endif
  endfunction

  " Loads a session if it exists
  function! LoadSession()
  if argc() == 0
  let b:sessionfile = $VIMSESSION
  let b:sessiondir = $XDG_DATA_HOME . "/nvim/sessions" . getcwd()
  let b:sessionfile = b:sessiondir . "/session.vim"
  if (filereadable(b:sessionfile))
  exe 'source ' b:sessionfile
  else
  echo "No session loaded."
  endif
  else
  let b:sessionfile = ""
  let b:sessiondir = ""
  endif
  endfunction

  au VimEnter * nested :call LoadSession()
  au VimLeave * :call UpdateSession()
  map <leader>s :call MakeSession()<CR>

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
''
