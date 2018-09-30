pkgs: {
  configure.customRC = import ./config.nix pkgs;
  configure.packages.plugins.opt = with pkgs.vimPlugins; [
    deoplete-clang
    deoplete-go
    deoplete-julia
    deoplete-rust
    vim-table-mode
  ];
  configure.packages.plugins.start = with pkgs.vimPlugins; [
    auto-pairs
    base16-vim
    denite
    deoplete-nvim
    editorconfig-vim
    fugitive
    fzf-vim
    fzfWrapper
    gitv
    incsearch-vim
    multiple-cursors
    neoinclude
    neomake
    neosnippet
    neosnippet-snippets
    nerdcommenter
    polyglot
    repeat
    surround
    tabular
    vim-abolish
    vim-airline
    vim-airline-themes
    vim-anzu
    vim-autoformat
    vim-bufferline
    vim-devicons
    vim-dirvish
    vim-ghost
    vim-plugin-AnsiEsc
    vim-polyglot
    vim-signify
    vim-unimpaired
    vim-visualstar
  ];
  configure.plug.plugins = with pkgs.vimPlugins; [
    vim-go
  ];

  extraPython3Packages = (ps: with ps; [ 
    python-slugify
    simple-websocket-server
  ]);

  viAlias = true;
  vimAlias = true;
  withPython = true;
  withPython3 = true;
  withRuby = true;
}
