{
  self,
  drawbridge,
  flake-utils,
  nixpkgs-nixos,
  steward,
  ...
}:
with flake-utils.lib.system;
  nixpkgs-nixos.lib.nixosSystem {
    system = x86_64-linux;
    modules = [
      ({
        config,
        lib,
        modulesPath,
        pkgs,
        ...
      }: {
        imports = [
          self.nixosModules.default

          "${modulesPath}/virtualisation/openstack-config.nix" # Gandi requirement

          drawbridge.nixosModules.default
          steward.nixosModules.default
        ];

        boot.initrd.kernelModules = [
          "xen-blkfront" # Gandi requirement
          "xen-fbfront" # Gandi requirement
          "xen-kbdfront" # Gandi requirement
          "xen-netfront" # Gandi requirement
          "xen-pcifront" # Gandi requirement
          "xen-scsifront" # Gandi requirement
          "xen-tpmfront" # Gandi requirement
        ];

        networking.domain = "dev";
        networking.firewall.allowedTCPPorts = [
          80
          443
        ];
        networking.hostName = "rvolosatovs";
        networking.tempAddresses = "disabled"; # Gandi requirement

        services.drawbridge.enable = true;
        services.drawbridge.log.level = "trace";
        services.drawbridge.oidc.audience = "https://store.${config.networking.fqdn}/";
        services.drawbridge.oidc.issuer = "https://dev-6v5yy47gee4ttqba.us.auth0.com/";
        services.drawbridge.tls.caFile = ../../hosts/attest.rvolosatovs.dev/steward.crt;

        services.nginx.enable = true;
        services.nginx.virtualHosts."attest.${config.networking.fqdn}" = {
          enableACME = true;
          forceSSL = true;
          http2 = false;
          locations."/".proxyPass = "http://localhost:3000";
        };

        services.steward.certFile = pkgs.writeText "steward.crt" (builtins.readFile "${self}/hosts/attest.rvolosatovs.dev/steward.crt");
        services.steward.enable = true;
        services.steward.keyFile = config.sops.secrets.steward-key.path;
        services.steward.log.level = "trace";

        sops.secrets.steward-key.format = "binary";
        sops.secrets.steward-key.group = config.users.users.steward.group;
        sops.secrets.steward-key.owner = config.users.users.steward.name;
        sops.secrets.steward-key.restartUnits = ["steward.service"];
        sops.secrets.steward-key.sopsFile = "${self}/hosts/attest.rvolosatovs.dev/steward.key";

        systemd.services.steward.serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];

        users.groups.steward = {};

        users.users.steward.isSystemUser = true;
        users.users.steward.group = config.users.groups.steward.name;

        # Gandi requirement
        systemd.services."getty@tty1" = {
          enable = lib.mkForce true;
          wantedBy = ["multi-user.target"];
          serviceConfig.Restart = "always";
        };

        time.timeZone = "Etc/UTC";
      })
    ];
  }
