pkgs: {
  configure.customRC = import ./config.nix pkgs;
  configure.packages.plugins.opt = with pkgs.vimPlugins; [
    vim-table-mode
    tabular
  ];
  configure.plug.plugins = with pkgs.vimPlugins; [
    auto-pairs
    base16-vim
    coc-html
    coc-json
    coc-lists
    coc-nvim
    coc-rls
    coc-yank
    direnv-vim
    editorconfig-vim
    fugitive
    gitv
    incsearch-vim
    neosnippet
    neosnippet-snippets
    nerdcommenter
    repeat
    surround
    vim-abolish
    vim-airline
    vim-airline-themes
    vim-anzu
    vim-bufferline
    vim-devicons
    vim-dirvish
    vim-dirvish-git
    vim-plugin-AnsiEsc
    vim-polyglot
    vim-signify
    vim-unimpaired
    vim-visual-multi
    vim-visualstar
  ];

  extraPython3Packages = (ps: with ps; [ 
    python-slugify
    simple-websocket-server
  ]);

  viAlias = true;
  vimAlias = true;
  withNodeJs = true;
  withPython = true;
  withPython3 = true;
  withRuby = true;
}
