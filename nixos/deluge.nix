{ config, lib, ... }:
with lib;
{
  services.deluge.enable = true;
  services.deluge.web.enable = true;

  services.nginx.enable = true;
  services.nginx.virtualHosts."deluge".enableACME = true;
  services.nginx.virtualHosts."deluge".forceSSL = true;
  services.nginx.virtualHosts."deluge".locations."/".proxyPass = "http://localhost:8112";
  services.nginx.virtualHosts."deluge".serverName = "deluge.${config.resources.domainName}";

  users.users.${config.resources.username}.extraGroups = [ "deluge" ];
}
