{ config, pkgs, ... }:
let
  httpPort = 24004;
in
  {
    services.nginx.enable = true;
    services.nginx.virtualHosts."news".addSSL = true;
    services.nginx.virtualHosts."news".enableACME = true;
    services.nginx.virtualHosts."news".locations."/".proxyPass = "http://localhost:${toString httpPort}";
    services.nginx.virtualHosts."news".serverName = "news.${config.resources.domainName}";

    services.miniflux.enable = true;
    services.miniflux.config.LISTEN_ADDR = "localhost:${toString httpPort}";
  }
