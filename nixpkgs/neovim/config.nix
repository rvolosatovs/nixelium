pkgs: ''
  if $TERM!="linux"
    let base16colorspace=256
  endif
  color base16-tomorrow-night
  set background=dark

  filetype plugin indent on
  syntax on

  let g:polyglot_disabled = ['go']

  set autoindent
  set autowriteall
  set backup
  set backupdir=~/.local/share/nvim/backup//
  set cmdheight=2
  set completeopt+=menuone,noinsert,noselect
  set concealcursor=nc
  set conceallevel=0
  set confirm
  set cursorcolumn
  set cursorline
  set encoding=utf-8
  set expandtab
  set fileencoding=utf-8
  set fileformat=unix
  set foldcolumn=auto:9
  set gdefault
  set grepformat^=%f:%l:%c:%m
  set grepprg=${pkgs.ripgrep}/bin/rg\ --vimgrep
  set guicursor=
  set hidden
  set hlsearch
  set ignorecase
  set incsearch
  set inccommand=nosplit
  set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>
  set mouse=a
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

  lua << EOF
    local lspconfig = require'lspconfig'
    local on_attach = function(_, bufnr)
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    end

    lspconfig.bashls.setup{
      on_attach = on_attach;
      cmd = { '${pkgs.nodePackages.bash-language-server}/bin/bash-language-server', 'start' };
    }
    lspconfig.clangd.setup{
      on_attach = on_attach;
      cmd = { '${pkgs.clang-tools}/bin/clangd', '--background-index' };
    }
    lspconfig.dockerls.setup{
      on_attach = on_attach;
      cmd = { '${pkgs.nodePackages.dockerfile-language-server-nodejs}/bin/docker-langserver', '--stdio' };
    }
    lspconfig.elmls.setup{
      on_attach = on_attach;
      cmd = { '${pkgs.elmPackages.elm-language-server}/bin/elm-language-server' };
      settings = {
        elmLS = {
          elmFormatPath = '${pkgs.elmPackages.elm-format}/bin/elm-format';
        };
        elmPath = '${pkgs.elmPackages.elm}/bin/elm';
        elmTestPath = '${pkgs.elmPackages.elm-test}/bin/elm-test';
      };
    }
    lspconfig.gdscript.setup{
      on_attach = on_attach;
    }
    lspconfig.gopls.setup{
      on_attach = on_attach;
      cmd = { '${pkgs.gopls}/bin/gopls' };
      settings = {
        gopls = {
          staticcheck = true;
          gofumpt = true;
        };
      };
    }
    lspconfig.julials.setup{
      on_attach = on_attach;
      settings = {
        julia = {
          executablePath = '${pkgs.julia}/bin/julia';
        };
      };
    }
    lspconfig.rnix.setup{
      on_attach = on_attach;
      cmd = { '${pkgs.rnix-lsp}/bin/rnix-lsp' };
    }
    lspconfig.rust_analyzer.setup{
      on_attach = on_attach;
      settings = {
        ['rust-analyzer'] = {
          serverPath = '${pkgs.rust-analyzer}/bin/rust-analyzer';
        };
      };
    }
  EOF

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

  let g:completion_enable_snippet = "vim-vsnip"

  let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

  let g:go_code_completion_enabled = 0
  let g:go_def_mapping_enabled = 0
  let g:go_fmt_autosave = 1
  let g:go_fmt_command = '${pkgs.gofumpt}/bin/gofumpt'
  let g:go_gopls_enabled = 0
  let g:go_highlight_array_whitespace_error = 1
  let g:go_highlight_build_constraints = 1
  let g:go_highlight_chan_whitespace_error = 1
  let g:go_highlight_function_calls = 1
  let g:go_highlight_functions = 1
  let g:go_highlight_generate_tags = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_trailing_whitespace_error = 1
  let g:go_test_show_name = 1

  let g:NERDCreateDefaultMappings = 0

  let g:rustc_path = '${pkgs.rustup}/bin/rustc'
  let g:rustfmt_autosave_if_config_present = 1

  function! OpenFloatingWindow(width, height)
    let buf = nvim_create_buf(v:false, v:true)
    call setbufvar(buf, '&signcolumn', 'no')

    let width = float2nr(&columns * a:width)
    call nvim_open_win(buf, v:true, {
    \   'relative': 'editor',
    \   'row': &lines * 2 / 10,
    \   'col': float2nr((&columns - width) / 2),
    \   'width': width,
    \   'height': float2nr(&lines * a:height)
    \ })
  endfunction

  let g:skim_layout = { 'window': 'call OpenFloatingWindow(0.6, 0.6)' }

  let g:loaded_netrwPlugin = 1

  let g:markdown_fenced_languages = ['css', 'js=javascript']

  let mapleader = "\<Space>"
  let maplocalleader = "\<Space>"

  imap                         <expr> <C-j>      vsnip#available(1)  ? '<Plug>(vsnip-expand)'         : '<C-j>'
  imap                         <expr> <C-l>      vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
  imap                         <expr> <S-Tab>    vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
  imap                         <expr> <Tab>      vsnip#available(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
  inoremap                     <A-h>             <C-\><C-N><C-w>h
  inoremap                     <A-j>             <C-\><C-N><C-w>j
  inoremap                     <A-k>             <C-\><C-N><C-w>k
  inoremap                     <A-l>             <C-\><C-N><C-w>l
  inoremap                     <expr> <S-Tab>    pumvisible() ? "\<C-p>" : "\<S-Tab>"
  inoremap                     <expr> <Tab>      pumvisible() ? "\<C-n>" : "\<Tab>"
  map                          <Leader>c$        <Plug>NERDCommenterToEOL
  map                          <Leader>cA        <Plug>NERDCommenterAppend
  map                          <Leader>c<Leader> <Plug>NERDCommenterToggle
  map                          <Leader>cy        <Plug>NERDCommenterYank
  nmap                         <C-]>             gd
  nnoremap                     K                 ddkPJ
  nnoremap            <silent> 1gD               <Cmd>lua vim.lsp.buf.type_definition()<CR>
  nnoremap            <silent> <C-]>             <Cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap            <silent> <C-k>             <Cmd>lua vim.lsp.buf.signature_help()<CR>
  nnoremap            <silent> <Leader>f         <Cmd>lua vim.lsp.buf.formatting()<CR>
  nnoremap            <silent> <Leader>i         <Cmd>lua vim.lsp.buf.code_action({context = 'organizeImport'})<CR>
  nnoremap            <silent> <Leader>r         <Cmd>lua vim.lsp.buf.rename()<CR>
  nnoremap            <silent> g0                <Cmd>lua vim.lsp.buf.document_symbol()<CR>
  nnoremap            <silent> gd                <Cmd>lua vim.lsp.buf.declaration()<CR>
  nnoremap            <silent> gD                <Cmd>lua vim.lsp.buf.implementation()<CR>
  nnoremap            <silent> gr                <Cmd>lua vim.lsp.buf.references()<CR>
  nnoremap            <silent> gW                <Cmd>lua vim.lsp.buf.workspace_symbol()<CR>
  noremap                      <A-h>             <C-w>h
  noremap                      <A-j>             <C-w>j
  noremap                      <A-k>             <C-w>k
  noremap                      <A-l>             <C-w>l
  noremap                      <Leader>:         :Commands<CR>
  noremap                      <Leader>a         :wa<CR>
  noremap                      <Leader>cd        :cd %:p:h<CR>:pwd<CR>
  noremap                      <Leader>cl        :copen<CR>
  noremap                      <Leader>cl        :copen<CR>
  noremap                      <Leader>cn        :cnext<CR>
  noremap                      <Leader>cN        :cprevious<CR>
  noremap                      <Leader>cP        :cnext<CR>
  noremap                      <Leader>cp        :cprevious<CR>
  noremap                      <Leader>g/        :History/<CR>
  noremap                      <Leader>g:        :History:<CR>
  noremap                      <Leader>gb        :Buffers<CR>
  noremap                      <Leader>gc        :Commits<CR>
  noremap                      <Leader>gd        :Helptags<CR>
  noremap                      <Leader>gf        :Files<CR>
  noremap                      <Leader>gg        :GFiles<CR>
  noremap                      <Leader>gh        :History<CR>
  noremap                      <Leader>gl        :BLines<CR>
  noremap                      <Leader>gL        :Lines<CR>
  noremap                      <Leader>gm        :Marks<CR>
  noremap                      <Leader>gs        :G<CR>
  noremap                      <Leader>gS        :GFiles?<CR>
  noremap                      <Leader>gt        :FileTypes<CR>
  noremap                      <Leader>gw        :Windows<CR>
  noremap                      <Leader>ll        :lopen<CR>
  noremap                      <Leader>ln        :lnext<CR>
  noremap                      <Leader>lN        :lprevious<CR>
  noremap                      <Leader>lP        :lnext<CR>
  noremap                      <Leader>lp        :lprevious<CR>
  noremap                      <Leader>q         :q<CR>
  noremap                      <Leader>s         :sort i<CR>
  noremap                      <Leader>w         :w<CR>
  noremap                      <Space>           <Nop>
  noremap                      Y                 y$
  smap                         <expr> <C-l>      vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
  smap                         <expr> <S-Tab>    vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
  smap                         <expr> <Tab>      vsnip#available(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
  tnoremap                     <A-h>             <C-\><C-N><C-w>h
  tnoremap                     <A-j>             <C-\><C-N><C-w>j
  tnoremap                     <A-k>             <C-\><C-N><C-w>k
  tnoremap                     <A-l>             <C-\><C-N><C-w>l

  command! -nargs=? -complete=dir Explore Dirvish <args>
  command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
  command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>

  au TextYankPost * silent! lua require'highlight'.on_yank("IncSearch", 500, vim.v.event)

  au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup noundofile

  " Highlight the symbol and its references when holding the cursor.
  au CursorHold             <silent> <buffer> lua vim.lsp.buf.hover()

  au FileType  markdown              packadd vim-table-mode
  au FileType  typescript            setlocal noexpandtab

  au BufEnter * lua require'completion'.on_attach()
''
