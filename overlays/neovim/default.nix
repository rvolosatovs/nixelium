inputs: pkgs @ {vimPlugins, ...}: {
  configure.customRC = import ./config.nix inputs pkgs;
  configure.packages.plugins.opt = with vimPlugins; [
    tabular
    vim-table-mode
  ];
  configure.packages.plugins.start = with vimPlugins; [
    nvim-lspconfig
    lsp_extensions-nvim

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
    gitv
    indent-blankline-nvim
    julia-vim
    nerdcommenter
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

  viAlias = true;
  vimAlias = true;
}
