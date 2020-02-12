{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "sonarr-unrus" ''
      if [ ''${sonarr_eventtype} == "Download" ]; then
        ${mkUnrusScript "\${sonarr_series_path}"}
      fi
    '')
  ];

  services.sonarr.enable = true;

  users.users.${config.resources.username}.extraGroups = [ "sonarr" ];
}
