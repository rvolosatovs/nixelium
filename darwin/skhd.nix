{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [
    config.services.skhd.package
  ];

  services.skhd.enable = true;
  services.skhd.skhdConfig = with config.resources.programs; ''
    cmd - return    : ${terminal.executable.path}&
    cmd + shift - o : ${browser.executable.path}
    cmd + shift - e : ${terminal.executable.path} -e "${shell.executable.path} -i -c ${editor.executable.path}"
  '';
}
