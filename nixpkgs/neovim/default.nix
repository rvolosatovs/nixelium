pkgs: {
  configure.customRC = import ./config.nix pkgs;
  configure.packages.plugins.opt = with pkgs.vimPlugins; [
    tabular
    vim-polyglot
    vim-table-mode
  ];
  configure.plug.plugins = with pkgs.vimPlugins; [
    nvim-lspconfig
    completion-nvim

    auto-pairs
    base16-vim
    editorconfig-vim
    fugitive
    gitv
    julia-vim
    nerdcommenter
    repeat
    rhubarb
    rust-vim
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
    vim-go
    vim-illuminate
    vim-plugin-AnsiEsc
    vim-signify
    vim-unimpaired
    vim-visual-multi
    vim-visualstar
    vim-vsnip
    vim-vsnip-integ
  ];

  extraPython3Packages = (
    ps: with ps; [
      python-slugify
      simple-websocket-server
    ]
  );

  viAlias = true;
  vimAlias = true;
  withNodeJs = true;
  withPython = true;
  withPython3 = true;
  withRuby = true;
}
