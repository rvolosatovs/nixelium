{ pkgs, ... }:
{
  imports = [
    ./../..
  ];

  config.resources = {
    base16.theme = "tomorrow-night";

    programs.terminal.executable.package = pkgs.kitty;
    programs.terminal.executable.name = "kitty -1";
  };
}
