pkgs: {
  configure.customRC = import ./config.nix pkgs;
  configure.packages.plugins.opt = with pkgs.vimPlugins; [
    tabular
    vim-table-mode
  ];
  configure.plug.plugins = with pkgs.vimPlugins; [
    nvim-lsp
    completion-nvim

    auto-pairs
    base16-vim
    direnv-vim
    editorconfig-vim
    fugitive
    gitv
    incsearch-vim
    julia-vim
    nerdcommenter
    repeat
    skim
    skim-vim
    surround
    vim-abolish
    vim-airline
    vim-airline-themes
    vim-anzu
    vim-bufferline
    vim-devicons
    vim-dirvish
    vim-eunuch
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
