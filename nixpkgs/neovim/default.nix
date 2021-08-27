pkgs: {
  configure.customRC = import ./config.nix pkgs;
  configure.packages.plugins.opt = with pkgs.vimPlugins; [
    tabular
    vim-polyglot
    vim-table-mode
  ];
  configure.plug.plugins = with pkgs.vimPlugins; [
    nvim-lspconfig
    lsp_extensions-nvim

    completion-nvim

    plenary-nvim

    nvim-dap
    nvim-treesitter
    popup-nvim
    telescope-nvim

    auto-pairs
    base16-vim
    editorconfig-vim
    gitv
    julia-vim
    nerdcommenter
    rust-tools-nvim
    rust-vim
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
    vim-repeat
    vim-rhubarb
    vim-signify
    vim-surround
    vim-unimpaired
    vim-visual-multi
    vim-visualstar
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
  withPython3 = true;
  withRuby = true;
}
