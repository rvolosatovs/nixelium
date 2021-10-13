{ pkgs, ... }:
{
  imports = [
    ./../..
  ];

  config.resources = {
    graphics.enable = true;
  };
}
