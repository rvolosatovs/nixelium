pkgs: {
  configure.customRC = import ./config.nix pkgs;
  configure.packages.plugins.opt = with pkgs.vimPlugins; [
    tabular
    vim-polyglot
    vim-table-mode
  ];
  configure.packages.plugins.start = with pkgs.vimPlugins; [
    nvim-lspconfig
    lsp_extensions-nvim

    nvim-cmp
    cmp-buffer
    cmp-nvim-lsp

    plenary-nvim

    nvim-dap
    nvim-treesitter
    popup-nvim
    telescope-nvim

    auto-pairs
    editorconfig-vim
    gitv
    julia-vim
    nerdcommenter
    nvim-base16
    nvim-web-devicons
    rust-tools-nvim
    rust-vim
    vim-abolish
    vim-airline
    vim-airline-themes
    vim-anzu
    vim-bufferline
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
