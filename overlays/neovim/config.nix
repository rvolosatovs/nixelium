{self, ...}: {
  fenix,
  julia,
  lib,
  lua-language-server,
  pkgsUnstable,
  ripgrep,
  stdenv,
  ...
}: let
  julia' =
    if julia.meta.unsupported
    then "julia"
    else "${julia}/bin/julia";

  paths = self.lib.toLua {
    bin.alejandra = "${pkgsUnstable.alejandra}/bin/alejandra";
    bin.bash-language-server = "${pkgsUnstable.nodePackages.bash-language-server}/bin/bash-language-server";
    bin.clangd = "${pkgsUnstable.clang-tools}/bin/clangd";
    bin.docker-langserver = "${pkgsUnstable.nodePackages.dockerfile-language-server-nodejs}/bin/docker-langserver";
    bin.gopls = "${pkgsUnstable.gopls}/bin/gopls";
    bin.haskell-language-server = "${pkgsUnstable.haskell-language-server}/bin/haskell-language-server-wrapper";
    bin.julia = julia';
    bin.lua-language-server = "${lua-language-server}/bin/lua-language-server";
    bin.nil = "${pkgsUnstable.nil}/bin/nil";
    bin.omnisharp = "${pkgsUnstable.omnisharp-roslyn}/bin/omnisharp";
    bin.ripgrep = "${ripgrep}/bin/rg";
    bin.rust-analyzer = "${fenix.stable.rust-analyzer}/bin/rust-analyzer";
    bin.taplo = "${pkgsUnstable.taplo}/bin/taplo";
    bin.typescript-language-server = "${pkgsUnstable.nodePackages.typescript-language-server}/bin/typescript-language-server";
    bin.vscode-css-language-server = "${pkgsUnstable.vscode-langservers-extracted}/bin/vscode-css-language-server";
    bin.vscode-eslint-language-server = "${pkgsUnstable.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
    bin.vscode-html-language-server = "${pkgsUnstable.vscode-langservers-extracted}/bin/vscode-html-language-server";
    src.lua-language-server = "${lua-language-server}";
  };
in ''
  filetype plugin indent on
  syntax enable

  set backupdir=~/.local/share/nvim/backup//
  set grepformat^=%f:%l:%c:%m
  set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>
  set shortmess+=c

  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()

  lua << EOF
    local paths = ${paths}
    ${lib.fileContents ./config.lua}
  EOF

  let g:airline#extensions#branch#enabled = 1
  let g:airline#extensions#syntastic#enabled = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#fnamemod = ':t'
  let g:airline#extensions#tabline#show_buffers = 1
  let g:airline#extensions#tabline#show_splits = 1
  let g:airline#extensions#tabline#tab_min_count = 1
  let g:airline#extensions#tabline#tab_nr_type = 2
  let g:airline#extensions#tagbar#enabled = 1
  let g:airline_powerline_fonts = 1
  let g:airline_theme='base16'

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

  let g:loaded_netrwPlugin = 1

  let g:markdown_fenced_languages = ['css', 'js=javascript']

  command! -nargs=? -complete=dir Explore Dirvish <args>
  command! -nargs=? -complete=dir Sexplore belowright split | silent Dirvish <args>
  command! -nargs=? -complete=dir Vexplore leftabove vsplit | silent Dirvish <args>

  au BufNewFile,BufRead /dev/shm/gopass.* setlocal noswapfile nobackup noundofile

  au FileType  markdown              packadd vim-table-mode
  au FileType  typescript            setlocal noexpandtab
''
