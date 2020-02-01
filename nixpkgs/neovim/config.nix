pkgs: 
let
  debug = false;
  gonicepls = pkgs.writeShellScript "gonicepls" ''
    ${pkgs.coreutils}/bin/nice -n 19 ${pkgs.gotools}/bin/gopls
  '';
in pkgs.lib.optionalString debug '' 
  let $NVIM_COC_LOG_LEVEL = 'debug' 

'' + ''
  if $TERM!="linux"
    let base16colorspace=256
  endif
  color base16-tomorrow-night
  set background=dark

  filetype plugin indent on
  syntax enable

  set autoindent
  set cmdheight=2
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
  set shortmess+=c
  set signcolumn=yes
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

  call coc#config('coc', {
  \ 'preferences': {
  \   'codeLens.enable': "true",
  \   'colorSupport': "true",
  \   'extensionUpdateCheck': "never",
  \   'formatOnSaveFiletypes': [ "go" ],
  \ },
  \ 'suggest': {
  \   'acceptSuggestionOnCommitCharacter': "true",
  \   'enablePreview': "true",
  \   'timeout': 2000,
  \   'triggerAfterInsertEnter': "true",
  \ },
  \})

  call coc#config('languageserver', {
  \ 'bash': {
  \   "command": "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server",
  \   "args": ["start"],
  \   "filetypes": ["sh"],
  \   "rootPatterns": [".vim/", ".git/", ".hg/"],
  \   "ignoredRootPaths": ["~"],
  \ },
'' + pkgs.lib.optionalString pkgs.stdenv.isLinux ''
  \ 'ccls': {
  \   "command": "${pkgs.ccls}/bin/ccls",
  \   "filetypes": ["c", "cpp", "cuda", "objc", "objcpp"],
  \   "rootPatterns": [".ccls", "compile_commands.json", ".vim/", ".git/", ".hg/"],
  \   "initializationOptions": {
  \      "cache": {
  \        "directory": ".ccls-cache",
  \      }
  \   },
  \ },
'' + ''
  \ 'dockerfile': {
  \   "command": "${pkgs.nodePackages.dockerfile-language-server-nodejs}/bin/docker-langserver",
  \   "filetypes": ["dockerfile"],
  \   "rootPatterns": [".vim/", ".git/", ".hg/"],
  \   "args": ["--stdio"],
  \ },
  \ 'golang': {
  \   "command": "${gonicepls}",
  \   "args": [],
  \   "rootPatterns": ["go.mod", ".vim/", ".git/", ".hg/"],
  \   "filetypes": ["go"],
  \ },
  \})

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
  let g:AutoPairsShortcutToggle = '<A-p>'

  let g:bufferline_echo = 0

  let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

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

  let g:incsearch#auto_nohlsearch = 1

  let g:jsx_ext_required = 0

  let g:loaded_netrwPlugin = 1

  let g:markdown_fenced_languages = ['css', 'js=javascript']

  let g:tex_conceal="ag"

'' + pkgs.lib.optionalString pkgs.stdenv.isLinux ''
  let g:vimtex_view_method='${pkgs.zathura}/bin/zathura'
'' +''

  let mapleader = "\<Space>"
  let maplocalleader = "\<Space>"

  imap                         <C-k>         <Plug>(neosnippet_expand_or_jump)
  inoremap                     <A-h>         <C-\><C-N><C-w>h
  inoremap                     <A-j>         <C-\><C-N><C-w>j
  inoremap                     <A-k>         <C-\><C-N><C-w>k
  inoremap                     <A-l>         <C-\><C-N><C-w>l
  nmap                         #             <Plug>(incsearch-nohl)<Plug>(anzu-sharp-with-echo)
  nmap                         *             <Plug>(incsearch-nohl)<Plug>(anzu-star-with-echo)
  nmap                         /             <Plug>(incsearch-forward)
  nmap                         <C-]>         gd
  nmap                         <Leader>f     <Plug>(coc-format-selected)
  nmap                         ?             <Plug>(incsearch-backward)
  nmap                         g#            <Plug>(incsearch-nohl-g#)<Plug>(anzu-update-search-status-with-echo)
  nmap                         g*            <Plug>(incsearch-nohl-g*)<Plug>(anzu-update-search-status-with-echo)
  nmap                         g/            <Plug>(incsearch-stay)
  nmap                         N             <Plug>(incsearch-nohl)<Plug>(anzu-N-with-echo)
  nmap                         n             <Plug>(incsearch-nohl)<Plug>(anzu-n-with-echo)
  nmap                         <Leader>R     <Plug>(coc-rename)
  nmap                <silent> [c            <Plug>(coc-diagnostic-prev)
  nmap                <silent> ]c            <Plug>(coc-diagnostic-next)
  nmap                <silent> gd            <Plug>(coc-definition)
  nmap                <silent> gi            <Plug>(coc-implementation)
  nmap                <silent> gr            <Plug>(coc-references)
  nmap                <silent> gy            <Plug>(coc-type-definition)
  nnoremap                     K             ddkPJ
  noremap                      ;             :
  noremap                      ;;            ;
  noremap                      <A-h>         <C-w>h
  noremap                      <A-j>         <C-w>j
  noremap                      <A-k>         <C-w>k
  noremap                      <A-l>         <C-w>l
  noremap                      <Leader>cd    :cd %:p:h<CR>:pwd<CR>
  noremap                      <Leader>cl    :copen<CR>
  noremap                      <Leader>cn    :cnext<CR>
  noremap                      <Leader>cp    :cprevious<CR>
  noremap                      <Leader>ll    :lopen<CR>
  noremap                      <Leader>ln    :lnext<CR>
  noremap                      <Leader>lp    :lprevious<CR>
  noremap                      <Leader>n     :bnext<CR>
  noremap                      <Leader>p     :bprev<CR>
  noremap                      <Leader>s     :sort i<CR>
  noremap                      <Leader>ze    :enew <CR>
  noremap                      <Leader>zt    :tabnew<CR>
  noremap                      <Space>       <Nop>
  noremap                      Y             y$
  smap                         <C-k>         <Plug>(neosnippet_expand_or_jump)
  tnoremap                     <A-h>         <C-\><C-N><C-w>h
  tnoremap                     <A-j>         <C-\><C-N><C-w>j
  tnoremap                     <A-k>         <C-\><C-N><C-w>k
  tnoremap                     <A-l>         <C-\><C-N><C-w>l
  vmap                         <Leader>f     <Plug>(coc-format-selected)
  xmap                         <C-k>         <Plug>(neosnippet_expand_target)

  au FileType go nmap <silent> <Leader>i     :call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>

  command! -nargs=? -complete=dir Explore Dirvish <args>
  command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
  command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>

  augroup Smartf
  autocmd User SmartfEnter :hi Conceal ctermfg=220 guifg=#6638F0
  autocmd User SmartfLeave :hi Conceal ctermfg=239 guifg=#504945
  augroup end

  au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup noundofile

  au FileType  markdown              packadd vim-table-mode
  au FileType  typescript            setlocal noexpandtab
  au FileType  verilog_systemverilog VerilogErrorFormat verilator 2
  au FileType  verilog_systemverilog setlocal makeprg=verilator\ --lint-only\ %

  au FocusLost *                     wa
''
