inputs @ {tree-sitter-cedar, ...}: pkgs @ {tree-sitter, vimPlugins, ...}: let
  treesitter-cedar = tree-sitter.buildGrammar {
    language = "cedar";
    version = tree-sitter-cedar.shortRev or "0";
    src = tree-sitter-cedar;
    location = "cedar";
  };
  treesitter-cedarschema = tree-sitter.buildGrammar {
    language = "cedarschema";
    version = tree-sitter-cedar.shortRev or "0";
    src = tree-sitter-cedar;
    location = "cedarschema";
  };

  nvim-treesitter = vimPlugins.nvim-treesitter.withPlugins (_: vimPlugins.nvim-treesitter.allGrammars ++ [
    treesitter-cedar
    treesitter-cedarschema
  ]);
in {
  configure.customRC = import ./config.nix inputs pkgs;
  configure.packages.plugins.opt = with vimPlugins; [
    tabular
    vim-table-mode
  ];
  configure.packages.plugins.start = with vimPlugins; [
    nvim-lspconfig

    plenary-nvim

    nvim-treesitter

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
