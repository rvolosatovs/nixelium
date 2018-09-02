{ config, pkgs, lib, ... }:
{
  services.nginx.enable = true;
  services.nginx.package = pkgs.nginxMainline;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
}
