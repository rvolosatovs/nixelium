{ pkgs, ... }:
{
  imports = [
    ./../..
  ];

  config.resources = {
    base16.theme = "tomorrow-night";
    graphics.enable = true;

    programs.terminal.package = pkgs.kitty;
    programs.terminal.executable.name = "kitty";
  };
}
