pkgs: pkgs.neovim.override {
  configure.customRC = import ./config.nix pkgs;
  configure.packages.myVimPackage.opt = with pkgs.vimPlugins; [
    deoplete-clang
    deoplete-go
    deoplete-julia
    deoplete-nvim
    deoplete-rust
    vim-go
    vim-table-mode
  ];
  configure.packages.myVimPackage.start = with pkgs.vimPlugins; [
    auto-pairs
    base16-vim
    denite
    editorconfig-vim
    fugitive
    fzf-vim
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
    vim-plugin-AnsiEsc
    vim-signify
    vim-snippets
    vim-unimpaired
    vim-visualstar
  ];
  viAlias = true;
  vimAlias = true;
  withPython = true;
  withPython3 = true;
  withRuby = true;
}
