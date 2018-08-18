{
  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;

  xdg.configFile."nvim/init.vim".source = ../dotfiles/nvim/init.vim;
  xdg.configFile."nvim/ftplugin".source = ../dotfiles/nvim/ftplugin;
}
