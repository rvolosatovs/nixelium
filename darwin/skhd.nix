{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    config.services.skhd.package
  ];

  services.skhd.enable = true;
  services.skhd.skhdConfig = with config.resources.programs; ''
    super + Return
        ${terminal.executable.path}

    super + shift + o
        ${browser.executable.path}

    super + shift + e
        ${terminal.executable.path} -e "${shell.executable.path} -i -c ${editor.executable.path}"
  '';
}
