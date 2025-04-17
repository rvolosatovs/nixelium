inputs: pkgs @ {pkgsMaster, ...}: {
  configure.customRC = import ./config.nix inputs pkgs;
  configure.packages.plugins.opt = with pkgsMaster.vimPlugins; [
    tabular
    vim-table-mode
  ];
  configure.packages.plugins.start = with pkgsMaster.vimPlugins; [
    nvim-lspconfig

    plenary-nvim

    nvim-treesitter.withAllGrammars

    luasnip

    nvim-cmp

    cmp-buffer
    cmp-calc
    cmp-emoji
    cmp_luasnip
    cmp-nvim-lsp
    cmp-nvim-lua
    cmp-path
    cmp-spell
    cmp-treesitter

    nvim-dap

    dressing-nvim
    telescope-nvim

    auto-pairs
    base16-vim
    editorconfig-vim
    indent-blankline-nvim
    julia-vim
    nerdcommenter
    nvim-web-devicons
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

  viAlias = true;
  vimAlias = true;
}
