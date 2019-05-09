{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    config.services.skhd.package
  ];

  services.skhd.enable = true;
  services.skhd.skhdConfig = with config.resources.programs; ''
    cmd + shift - e : ${terminal.executable.path} -e "${shell.executable.path} -i -c ${editor.executable.path}"
    cmd + shift - o : ${browser.executable.path}
    cmd - return    : ${terminal.executable.path}&
  '';
}
