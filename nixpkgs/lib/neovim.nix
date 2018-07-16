{ pkgs, dotDir, ... }:

{
  programs.neovim.enable = true;
  #programs.neovim.vimAlias = true;

  xdg.configFile."nvim/init.vim".source = dotDir + "/nvim/init.vim";
  xdg.configFile."nvim/ftplugin".source = dotDir + "/nvim/ftplugin";
}
