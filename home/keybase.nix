{ config, pkgs, lib, ... }:

{
  config = with lib; mkMerge [
    (mkIf pkgs.stdenv.isLinux {
      services.kbfs.enable = true;
      services.kbfs.mountPoint = ".local/keybase";
      services.keybase.enable = true;
    })
  ];
}
