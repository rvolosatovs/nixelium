{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "sonarr-engify" ''
      if [ "''${sonarr_eventtype}" = "Download" ]; then
        ${pkgs.engify}/bin/engify "''${sonarr_series_path}"
      fi
    '')
  ];

  services.sonarr.enable = true;

  users.users.${config.resources.username}.extraGroups = ["sonarr"];
}
