pkgs: ''
  set packpath-=~/.vim/after

  so ${pkgs.vimPlugins.vim-plug.rtp}/plug.vim
  call plug#begin('/dev/null')
  Plug '${pkgs.vimPlugins.vim-go.rtp}', { 'for': 'go' }
  call plug#end()

  function! Multiple_cursors_before()
    if exists("g:deoplete#disable_auto_complete")
      let g:deoplete#disable_auto_complete = 1
    endif
  endfunction

  function! Multiple_cursors_after()
    if exists("g:deoplete#disable_auto_complete")
      let g:deoplete#disable_auto_complete = 0
    endif
  endfunction


  function! MakeSession()
    let b:sessiondir = $XDG_DATA_HOME . "/nvim/sessions" . getcwd()
    if (filewritable(b:sessiondir) != 2)
      exe "silent !mkdir -p " b:sessiondir
      redraw!
    endif
    let b:sessionfile = b:sessiondir . "/session.vim"
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

  function! LoadSession()
    if argc() == 0
      let b:sessionfile = $VIMSESSION
      let b:sessiondir = $XDG_DATA_HOME . "/nvim/sessions" . getcwd()
      let b:sessionfile = b:sessiondir . "/session.vim"
      if (filereadable(b:sessionfile))
        exe "source " b:sessionfile
      else
        echo "No session loaded."
      endif
    else
      let b:sessionfile = ""
      let b:sessiondir = ""
    endif
  endfunction

  if $TERM!="linux"
    let base16colorspace=256
  endif
  color base16-tomorrow-night
  set background=dark

  filetype plugin indent on
  syntax enable

  set autoindent
  set completeopt+=menu,menuone
  set concealcursor=nc
  set conceallevel=0
  set cursorcolumn
  set cursorline
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
  set grepprg=${pkgs.ripgrep}/bin/rg\ --vimgrep
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
  set t_Co=256
  set tabstop=4
  set termguicolors
  set title
  set undofile
  set updatetime=250
  set viewoptions=cursor,slash,unix
  set visualbell
  set wrapscan

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

  let g:AutoPairsFlyMode = 0
  let g:AutoPairsShortcutToggle = '<C-P>'

  let g:bufferline_echo = 0

  let g:deoplete#enable_at_startup = 1

  let g:deoplete#sources#clang#clang_header="${pkgs.llvmPackages.clang-unwrapped}/lib/clang"
  let g:deoplete#sources#clang#libclang_path="${pkgs.llvmPackages.libclang}/lib/libclang.so"

  let g:deoplete#sources#go#auto_goos = 1
  let g:deoplete#sources#go#cgo = 0
  let g:deoplete#sources#go#gocode_binary = '${pkgs.gocode}/bin/gocode'
  let g:deoplete#sources#go#package_dot = 0
  let g:deoplete#sources#go#pointer = 1
  let g:deoplete#sources#go#sort_class = ['package', 'var', 'func', 'const', 'type']

  let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

  let g:go_auto_type_info = 0
  let g:go_doc_command = '${pkgs.gotools}/bin/godoc'
  let g:go_fmt_autosave = 1
  let g:go_fmt_command = '${pkgs.gotools}/bin/goimports'
  let g:go_highlight_array_whitespace_error = 1
  let g:go_highlight_build_constraints = 1
  let g:go_highlight_chan_whitespace_error = 1
  let g:go_highlight_extra_types = 0
  let g:go_highlight_fields = 0
  let g:go_highlight_format_strings = 1
  let g:go_highlight_function_arguments = 0
  let g:go_highlight_function_calls = 1
  let g:go_highlight_functions = 1
  let g:go_highlight_generate_tags = 1
  let g:go_highlight_interfaces = 0
  let g:go_highlight_methods = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_structs = 1
  let g:go_highlight_trailing_whitespace_error = 1
  let g:go_highlight_types = 0
  let g:go_highlight_variable_assignments = 0
  let g:go_highlight_variable_declarations = 0
  let g:go_snippet_engine = "neosnippet"

  let g:incsearch#auto_nohlsearch = 1

  let g:jsx_ext_required = 0

  let g:multi_cursor_exit_from_insert_mode = 0
  let g:multi_cursor_exit_from_visual_mode = 0

  let g:neomake_open_list=1

  let g:polyglot_disabled = [ 'go' ]

  let g:sneak#label = 1
  let g:sneak#s_next = 1
  let g:sneak#target_labels = 'hjkluiobnmxcvwersdfg'
  let g:sneak#use_ic_scs = 1

  let g:tex_conceal="ag"

  let g:vimtex_view_method='${pkgs.zathura}/zathura'

  let mapleader = "\<Space>"
  let maplocalleader = "\<Space>"

  imap     <C-k>         <Plug>(neosnippet_expand_or_jump)
  imap     <C-x><C-f>    <Plug>(fzf-complete-path)
  imap     <C-x><C-j>    <Plug>(fzf-complete-file-ag)
  imap     <C-x><C-l>    <Plug>(fzf-complete-line)
  inoremap <A-h>         <C-\><C-N><C-w>h
  inoremap <A-j>         <C-\><C-N><C-w>j
  inoremap <A-k>         <C-\><C-N><C-w>k
  inoremap <A-l>         <C-\><C-N><C-w>l
  nmap     #             <Plug>(incsearch-nohl)<Plug>(anzu-sharp-with-echo)
  nmap     *             <Plug>(incsearch-nohl)<Plug>(anzu-star-with-echo)
  nmap     /             <Plug>(incsearch-forward)
  nmap     <Leader><Tab> <Plug>(fzf-maps-n)
  nmap     ?             <Plug>(incsearch-backward)
  nmap     g#            <Plug>(incsearch-nohl-g#)<Plug>(anzu-update-search-status-with-echo)
  nmap     g*            <Plug>(incsearch-nohl-g*)<Plug>(anzu-update-search-status-with-echo)
  nmap     g/            <Plug>(incsearch-stay)
  nmap     N             <Plug>(incsearch-nohl)<Plug>(anzu-N-with-echo)
  nmap     n             <Plug>(incsearch-nohl)<Plug>(anzu-n-with-echo)
  nnoremap K             i<CR><Esc>
  noremap  ;             :
  noremap  ;;            ;
  noremap  <A-h>         <C-w>h
  noremap  <A-j>         <C-w>j
  noremap  <A-k>         <C-w>k
  noremap  <A-l>         <C-w>l
  noremap  <Leader>af    :Autoformat<CR>
  noremap  <Leader>cd    :cd %:p:h<CR>:pwd<CR>
  noremap  <Leader>f:    :Commands<CR>
  noremap  <Leader>f;    :History:<CR>
  noremap  <Leader>fb    :Buffers <CR>
  noremap  <Leader>fg    :BCommits<CR>
  noremap  <Leader>fG    :Commits<CR>
  noremap  <Leader>fh    :History<CR>
  noremap  <Leader>fl    :BLines <CR>
  noremap  <Leader>fL    :Lines <CR>
  noremap  <Leader>fm    :Marks<CR>
  noremap  <Leader>fs    :Snippets<CR>
  noremap  <Leader>ft    :BTags<CR>
  noremap  <Leader>fT    :Tags<CR>
  noremap  <Leader>fw    :Windows<CR>
  noremap  <Leader>M     :Neomake!<CR>
  noremap  <Leader>m     :Neomake<CR>
  noremap  <Leader>o     :Files %:p:h<CR>
  noremap  <Leader>O     :GFiles <CR>
  noremap  <Leader>s     :call MakeSession()<CR>
  noremap  <Leader>ze    :enew <CR>
  noremap  <Leader>zt    :tabnew<CR>
  noremap  <Space>       <Nop>
  noremap  Y             y$
  omap     <Leader><Tab> <Plug>(fzf-maps-o)
  smap     <C-k>         <Plug>(neosnippet_expand_or_jump)
  tnoremap <A-h>         <C-\><C-N><C-w>h
  tnoremap <A-j>         <C-\><C-N><C-w>j
  tnoremap <A-k>         <C-\><C-N><C-w>k
  tnoremap <A-l>         <C-\><C-N><C-w>l
  xmap     <C-k>         <Plug>(neosnippet_expand_target)
  xmap     <Leader><Tab> <Plug>(fzf-maps-x)

  au FileType  c                     packadd deoplete-clang
  au FileType  conf                  inoremap <buffer> ## <Esc>79i#<Esc>yypO#<Space>
  au FileType  cpp                   packadd deoplete-clang
  au FileType  csharp                packadd deoplete-clang
  au FileType  dirvish               call fugitive#detect(@%)
  au FileType  go                    packadd deoplete-go
  au FileType  go call               deoplete#custom#source('go', 'rank', 9999)
  au FileType  go nmap               <Leader>C <Plug>(go-coverage)
  au FileType  go nmap               <Leader>R <Plug>(go-run)
  au FileType  go nmap               <Leader>T <Plug>(go-test)
  au FileType  julia                 packadd deoplete-julia
  au FileType  markdown              packadd vim-table-mode
  au FileType  rust                  packadd deoplete-rust
  au FileType  typescript            setlocal noexpandtab
  au FileType  verilog_systemverilog VerilogErrorFormat verilator 2
  au FileType  verilog_systemverilog setlocal makeprg=verilator\ --lint-only\ %

  au FocusLost *                     wa
  au VimEnter  * nested              call LoadSession()
  au VimLeave  *                     call UpdateSession()
''
