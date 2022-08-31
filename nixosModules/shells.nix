{...}: {pkgs, ...}: {
  environment.shells = with pkgs; [
    pkgs.bashInteractive
  ];

  programs.bash.enableCompletion = true;

  programs.zsh.enableBashCompletion = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.interactiveShellInit = "source '${pkgs.grml-zsh-config}/etc/zsh/zshrc'";
}
