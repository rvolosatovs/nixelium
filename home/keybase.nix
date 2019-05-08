{ config, pkgs, lib, ... }:

{
  config = with lib; mkMerge [
    (mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        keybase
      ];

      services.kbfs.enable = true;
      services.kbfs.mountPoint = ".local/keybase";
      services.keybase.enable = true;
    })
  ];
}
