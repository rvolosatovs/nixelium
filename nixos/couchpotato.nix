{ config, lib, ... }:
with lib;
mkMerge [
  {
    services.couchpotato.enable = true;
  }
  (mkIf config.services.nginx.enable {
    services.nginx.virtualHosts."couchpotato".enableACME = true;
    services.nginx.virtualHosts."couchpotato".forceSSL = true;
    services.nginx.virtualHosts."couchpotato".locations."/".proxyPass = "http://localhost:5050";
  })
]
