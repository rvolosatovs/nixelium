{
  config,
  pkgs,
  ...
}: {
  services.nginx.enable = true;
  services.nginx.virtualHosts.dumpster.enableACME = true;
  services.nginx.virtualHosts.dumpster.forceSSL = true;
  services.nginx.virtualHosts.dumpster.locations."/".proxyPass = "http://localhost:24003";
  services.nginx.virtualHosts.dumpster.serverName = "dumpster.${config.resources.domainName}";
  services.nginx.virtualHosts.dumpster.extraConfig = ''
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
  '';

  systemd.services.dumpster.after = ["network.target"];
  systemd.services.dumpster.description = "Dumpster service";
  systemd.services.dumpster.enable = true;
  systemd.services.dumpster.serviceConfig.ExecStart = "${pkgs.dumpster}/bin/dumpster -http :24003";
  systemd.services.dumpster.serviceConfig.User = "dumpster";
  systemd.services.dumpster.wantedBy = ["multi-user.target"];

  users.users.dumpster = {
    createHome = true;
    description = "Dumpster user";
    home = "/var/lib/dumpster";
  };
}
