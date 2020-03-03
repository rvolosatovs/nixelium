{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "radarr-unrus" ''
      if [ "''${radarr_eventtype}" = "Download" ]; then
        ${mkUnrusScript "\${radarr_movie_path}"}
      fi
    '')
  ];

  services.radarr.enable = true;

  users.users.${config.resources.username}.extraGroups = [ "radarr" ];
}
