pkgs:
let
  julia = pkgs.julia_16-bin;
in
''
  if $TERM!='linux'
    let base16colorspace=256
  endif
  color base16-tomorrow-night
  set background=dark

  filetype plugin indent on
  syntax enable

  " by some reason XML support conflicts with Rust.
  " perhaps related to https://github.com/NixOS/nixpkgs/issues/118953
  let g:polyglot_disabled = ['go', 'rust', 'haskell', 'xml']
  packadd vim-polyglot

  set backupdir=~/.local/share/nvim/backup//
  set grepformat^=%f:%l:%c:%m
  set grepprg=${pkgs.ripgrep}/bin/rg\ --vimgrep
  set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>
  set shortmess+=c
  set t_Co=256

  lua << EOF
    --- Imports

    require('lsp_extensions')

    local completion = require('completion')
    local illuminate = require('illuminate')

    telescope = require('telescope.builtin')

    --- Functions

    function goimports(bufnr, timeoutms)
      local context = { source = { organizeImports = true } }
      vim.validate { context = { context, 't', true } }

      local params = vim.lsp.util.make_range_params()
      params.context = context

      local method = 'textDocument/codeAction'
      local resp = vim.lsp.buf_request_sync(bufnr, method, params, timeoutms)
      if resp and resp[1] then
        local result = resp[1].result
        if result and result[1] then
          local edit = result[1].edit
          vim.lsp.util.apply_workspace_edit(edit)
        end
      end
      vim.lsp.buf.formatting()
    end

    function noremap_fn_buf(bufnr, bind, command)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', bind, '<cmd>lua '..command..'<CR>', { noremap = true })
    end

    --- Options

    vim.opt.autoindent = true
    vim.opt.autowriteall = true
    vim.opt.backup = true
    vim.opt.cmdheight = 2
    vim.opt.completeopt = 'menuone,noinsert,noselect'
    vim.opt.concealcursor = 'nc'
    vim.opt.conceallevel = 0
    vim.opt.confirm = true
    vim.opt.cursorcolumn = true
    vim.opt.cursorline = true
    vim.opt.encoding = 'utf-8'
    vim.opt.expandtab = true
    vim.opt.fileencoding = 'utf-8'
    vim.opt.fileformat = 'unix'
    vim.opt.foldcolumn = 'auto:9'
    vim.opt.gdefault = true
    vim.opt.guicursor = ""
    vim.opt.hidden = true
    vim.opt.hlsearch = true
    vim.opt.ignorecase = true
    vim.opt.incsearch = true
    vim.opt.inccommand = 'nosplit'
    vim.opt.mouse = 'a'
    vim.opt.nrformats = 'alpha,octal,hex,bin'
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.shiftwidth = 4
    vim.opt.signcolumn = 'yes'
    vim.opt.smartcase = true
    vim.opt.softtabstop = 4
    vim.opt.tabstop = 4
    vim.opt.termguicolors = true
    vim.opt.title = true
    vim.opt.undofile = true
    vim.opt.updatetime = 250
    vim.opt.viewoptions = 'cursor,slash,unix'
    vim.opt.visualbell = true
    vim.opt.wrapscan = true

    -- use space as the leader key
    vim.g.mapleader = ' '

    --- Autocommands

    vim.api.nvim_command [[ autocmd TextYankPost * silent! lua require('highlight').on_yank('IncSearch', 500, vim.v.event) ]]

    --- Keybindings

    table.foreach({
      ['<leader>-']  = 'telescope.file_browser()',
      ['<leader>/']  = 'telescope.current_buffer_fuzzy_find()',
      ['<leader>:']  = 'telescope.commands()',
      ['<leader>ff'] = 'telescope.find_files()',
      ['<leader>fT'] = 'telescope.filetypes()',
      ['<leader>ft'] = 'telescope.tagstack()',
      ['<leader>g/'] = 'telescope.search_history()',
      ['<leader>g:'] = 'telescope.command_history()',
      ['<leader>gb'] = 'telescope.buffers()',
      ['<leader>gg'] = 'telescope.git_files()',
      ['<leader>gH'] = 'telescope.help_tags()',
      ['<leader>gh'] = 'telescope.oldfiles()',
      ['<leader>gj'] = 'telescope.jumplist()',
      ['<leader>gl'] = 'telescope.git_bcommits()',
      ['<leader>gL'] = 'telescope.loclist()',
      ['<leader>gM'] = 'telescope.man_pages()',
      ['<leader>gm'] = 'telescope.marks()',
      ['<leader>go'] = 'telescope.vim_options()',
      ['<leader>gp'] = 'telescope.builtin()',
      ['<leader>gq'] = 'telescope.quickfix()',
      ['<leader>gR'] = 'telescope.registers()',
      ['<leader>gs'] = 'telescope.git_status()',
      ['<leader>gt'] = 'telescope.git_commits()',
      ['<leader>gy'] = 'telescope.git_stash()',
      ['<leader>sp'] = 'telescope.spell_suggest()',
      ['<leader>ts'] = 'telescope.treesitter()',
    }, function (bind, command)
      vim.api.nvim_set_keymap('n', bind, '<cmd>lua '..command..'<CR>', { noremap = true })
    end)

    --- LSP

    local on_attach = function(client, bufnr)
      print('LSP loaded.')

      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

      completion.on_attach(client)
      illuminate.on_attach(client)

      table.foreach({
        ['<c-]>']      = 'telescope.lsp_definitions()',
        ['<c-k>']      = 'vim.lsp.buf.signature_help()',
        ['<leader>a']  = 'telescope.lsp_code_actions()',
        ['<leader>A']  = 'telescope.lsp_range_code_actions()',
        ['<leader>dd'] = 'telescope.lsp_document_diagnostics()',
        ['<leader>dl'] = 'vim.lsp.diagnostic.set_loclist()',
        ['<leader>f']  = 'vim.lsp.buf.formatting()',
        ['<leader>r']  = 'vim.lsp.buf.rename()',
        ['<leader>wa'] = 'vim.lsp.buf.add_workspace_folder()',
        ['<leader>wl'] = 'print(vim.inspect(vim.lsp.buf.list_workspace_folders()))',
        ['<leader>wr'] = 'vim.lsp.buf.remove_workspace_folder()',
        ['[d']         = 'vim.lsp.diagnostic.goto_prev()',
        [']d']         = 'vim.lsp.diagnostic.goto_next()',
        ['gc']         = 'vim.lsp.buf.incoming_calls()',
        ['gC']         = 'vim.lsp.buf.outgoing_calls()',
        ['gd']         = 'telescope.lsp_implementations()',
        ['gD']         = 'vim.lsp.buf.declaration()',
        ['gr']         = 'telescope.lsp_references()',
        ['gs']         = 'telescope.lsp_document_symbols()',
        ['gS']         = 'telescope.lsp_dynamic_workspace_symbols()',
        ['gT']         = 'vim.lsp.buf.type_definition()',
        ['K']          = 'vim.lsp.buf.hover()',
      }, function(bind, command) noremap_fn_buf(bufnr, bind, command) end)

      vim.api.nvim_command [[ hi def link LspReferenceText CursorLine ]]
    end

    require('rust-tools').setup({
      server = {
        on_attach = on_attach;
        settings = {
          ['rust-analyzer'] = {
            serverPath = '${pkgs.rust-analyzer}/bin/rust-analyzer';
          };
        };
      }
    })

    local lspconfig = require('lspconfig')
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
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        noremap_fn_buf(bufnr, '<leader>i', 'goimports(bufnr, 10000)')
      end;
      cmd = { '${pkgs.gopls}/bin/gopls', 'serve' };
      settings = {
        gopls = {
          analyses = {
           fieldalignment = true;
           unusedparams = true;
          };
          gofumpt = true;
          staticcheck = true;
        };
      };
    }
    lspconfig.hls.setup{
      on_attach = on_attach;
    }
    lspconfig.julials.setup{
      on_attach = on_attach;
      settings = {
        julia = {
          executablePath = '${julia}/bin/julia';
        };
      };
    }
    lspconfig.rnix.setup{
      on_attach = on_attach;
      cmd = { '${pkgs.rnix-lsp}/bin/rnix-lsp' };
    }

    --- Diagnostics

    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = true,
      }
    )
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

  let g:completion_enable_snippet = 'vim-vsnip'

  let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

  let g:go_code_completion_enabled = 0
  let g:go_def_mapping_enabled = 0
  let g:go_fmt_autosave = 0
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
  let g:rust_clip_command = '${pkgs.wl-clipboard}/bin/wl-copy'

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
  map                          <Leader>c<Leader> <Plug>NERDCommenterToggle
  map                          <Leader>cA        <Plug>NERDCommenterAppend
  map                          <Leader>cy        <Plug>NERDCommenterYank
  noremap                      <A-h>             <C-w>h
  noremap                      <A-j>             <C-w>j
  noremap                      <A-k>             <C-w>k
  noremap                      <A-l>             <C-w>l
  noremap                      <Leader>cd        :cd %:p:h<CR>:pwd<CR>
  noremap                      <Leader>cl        :copen<CR>
  noremap                      <Leader>cl        :copen<CR>
  noremap                      <Leader>cn        :cnext<CR>
  noremap                      <Leader>cN        :cprevious<CR>
  noremap                      <Leader>cP        :cnext<CR>
  noremap                      <Leader>cp        :cprevious<CR>
  noremap                      <Leader>ll        :lopen<CR>
  noremap                      <Leader>ln        :lnext<CR>
  noremap                      <Leader>lN        :lprevious<CR>
  noremap                      <Leader>lP        :lnext<CR>
  noremap                      <Leader>lp        :lprevious<CR>
  noremap                      <Leader>q         :q<CR>
  noremap                      <Leader>w         :w<CR>
  noremap                      <Leader>W         :wa<CR>
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

  au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup noundofile

  au FileType  markdown              packadd vim-table-mode
  au FileType  typescript            setlocal noexpandtab
''
