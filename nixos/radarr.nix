{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "radarr-engify" ''
      if [ "''${radarr_eventtype}" = "Download" ]; then
        ${pkgs.engify}/bin/engify "''${radarr_movie_path}"
      fi
    '')
  ];

  services.radarr.enable = true;

  users.users.${config.resources.username}.extraGroups = [ "radarr" ];
}
