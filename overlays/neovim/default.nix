inputs: pkgs @ {vimPlugins, ...}: {
  configure.customRC = import ./config.nix inputs pkgs;
  configure.packages.plugins.opt = with vimPlugins; [
    tabular
    vim-table-mode
  ];
  configure.packages.plugins.start = with vimPlugins; [
    nvim-lspconfig

    plenary-nvim

    nvim-treesitter.withAllGrammars

    nvim-dap

    dressing-nvim
    telescope-nvim

    blink-cmp
    editorconfig-vim
    indent-blankline-nvim
    julia-vim
    mini-base16
    mini-bracketed
    mini-pairs
    mini-surround
    nvim-web-devicons
    rust-vim
    vim-abolish
    vim-airline
    vim-airline-themes
    vim-anzu
    vim-dirvish
    vim-eunuch
    vim-go
    vim-illuminate
    vim-plugin-AnsiEsc
    vim-repeat
    vim-rhubarb
    vim-signify
    vim-visual-multi
    vim-visualstar
  ];

  viAlias = true;
  vimAlias = true;
}
