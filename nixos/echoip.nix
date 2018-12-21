{ config, pkgs, ... }:
{
  services.nginx.enable = true;
  services.nginx.virtualHosts."ifconfig".enableACME = true;
  services.nginx.virtualHosts."ifconfig".forceSSL = true;
  services.nginx.virtualHosts."ifconfig".locations."/".proxyPass = "http://localhost:24002";
  services.nginx.virtualHosts."ifconfig".serverName = "ifconfig.${config.resources.domainName}";
  services.nginx.virtualHosts."ifconfig".extraConfig = ''
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
  '';

  systemd.services.echoip.after = [ "network.target" ];
  systemd.services.echoip.description = "Echoip service";
  systemd.services.echoip.enable = true;
  systemd.services.echoip.serviceConfig.ExecStart = "${pkgs.echoip}/bin/echoip -l :24002 -H X-Real-IP -t ${pkgs.echoip.out}/index.html -p";
  systemd.services.echoip.serviceConfig.User = "echoip";
  systemd.services.echoip.wantedBy = [ "multi-user.target" ];

  users.users.echoip.description = "Echoip user";
}
