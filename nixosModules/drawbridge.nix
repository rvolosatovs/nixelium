{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.drawbridge;
in {
  config = mkMerge [
    (mkIf cfg.enable {
      services.drawbridge.tls.caFile = pkgs.writeText "ca.crt" (builtins.readFile "${self}/ca/${config.networking.domain}/ca.crt");

      services.nginx.clientMaxBodySize = "100m";
      services.nginx.enable = true;
    })
  ];
}
