{ config, ... }:
{
  services.couchpotato.enable = true;

  services.nginx.enable = true;
  services.nginx.virtualHosts."couchpotato".enableACME = true;
  services.nginx.virtualHosts."couchpotato".forceSSL = true;
  services.nginx.virtualHosts."couchpotato".locations."/".proxyPass = "http://localhost:5050";
  services.nginx.virtualHosts."couchpotato".serverName = "couchpotato.${config.resources.domainName}";
}
