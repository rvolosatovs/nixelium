inputs: pkgs @ {pkgsMaster, ...}: {
  configure.customRC = import ./config.nix inputs pkgs;
  configure.packages.plugins.opt = with pkgsMaster.vimPlugins; [
    tabular
    vim-table-mode
  ];
  configure.packages.plugins.start = with pkgsMaster.vimPlugins; [
    plenary-nvim

    auto-pairs
    base16-vim
    dressing-nvim
    editorconfig-vim
    indent-blankline-nvim
    julia-vim
    nerdcommenter
    nvim-dap
    nvim-lspconfig
    nvim-treesitter.withAllGrammars
    nvim-web-devicons
    rust-vim
    telescope-nvim
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

  viAlias = true;
  vimAlias = true;
}
