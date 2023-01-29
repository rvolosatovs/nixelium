{
  self,
  drawbridge,
  flake-utils,
  nixpkgs,
  sops-nix,
  steward,
  ...
}:
with flake-utils.lib.system;
  nixpkgs.lib.nixosSystem {
    system = x86_64-linux;
    modules = [
      ({
        config,
        lib,
        modulesPath,
        pkgs,
        ...
      }: let
        # systemPath is the path where the system being activated is uploaded by `deploy`.
        systemPath = "/nix/store/*-activatable-nixos-system-${config.networking.hostName}-*";

        nopasswd = command: {
          inherit command;
          options = ["NOPASSWD" "SETENV"];
        };
      in
        with lib; {
          imports = [
            "${modulesPath}/virtualisation/openstack-config.nix" # Gandi requirement

            sops-nix.nixosModules.sops

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

          environment.systemPackages = with pkgs; [
            curl
            openssl
            tailscale
          ];

          environment.shells = with pkgs; [
            pkgs.bashInteractive
          ];

          networking.domain = "dev";
          networking.firewall.allowedTCPPorts = [
            80
            443
          ];
          networking.hostName = "rvolosatovs";
          networking.tempAddresses = "disabled"; # Gandi requirement

          nix.extraOptions = "experimental-features = nix-command flakes";
          nix.gc.automatic = true;
          nix.optimise.automatic = true;
          nix.package = pkgs.nixUnstable;
          nix.settings.allowed-users = with config.users; [
            "@${groups.deploy.name}"
            "@${groups.wheel.name}"
            users.root.name
          ];
          nix.settings.auto-optimise-store = true;
          nix.settings.require-sigs = true;
          nix.settings.substituters = [
            "https://cache.nixos.org"
            "https://enarx.cachix.org"
          ];
          nix.settings.trusted-users = with config.users; [
            "@${groups.deploy.name}"
            users.root.name
          ];
          nix.settings.trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "enarx.cachix.org-1:Izq345bPMThAWUW830X3uoGTTBjXW7ltGlfTBErgm4w="
          ];

          programs.bash.enableCompletion = true;

          programs.neovim.defaultEditor = true;
          programs.neovim.enable = true;
          programs.neovim.viAlias = true;
          programs.neovim.vimAlias = true;

          programs.zsh.autosuggestions.enable = true;
          programs.zsh.enable = true;
          programs.zsh.enableBashCompletion = true;
          programs.zsh.enableCompletion = true;
          programs.zsh.interactiveShellInit = "source '${pkgs.grml-zsh-config}/etc/zsh/zshrc'";

          security.acme.acceptTerms = true;
          security.acme.defaults.email = "rvolosatovs@riseup.net";

          security.sudo.enable = true;
          security.sudo.extraRules = [
            {
              groups = with config.users.groups; [deploy.name];
              runAs = config.users.users.root.name;
              commands = [
                (nopasswd "${systemPath}/activate-rs activate *")
                (nopasswd "${systemPath}/activate-rs wait *")
                (nopasswd "/run/current-system/sw/bin/rm /tmp/deploy-rs*")
              ];
            }
          ];
          security.sudo.wheelNeedsPassword = false;

          services.drawbridge.enable = true;
          services.drawbridge.log.level = "trace";
          services.drawbridge.oidc.audience = "https://store.${config.networking.fqdn}/";
          services.drawbridge.oidc.issuer = "https://dev-6v5yy47gee4ttqba.us.auth0.com/";
          services.drawbridge.tls.caFile = ../../hosts/attest.rvolosatovs.dev/steward.crt;

          services.nginx.enable = true;
          services.nginx.recommendedGzipSettings = true;
          services.nginx.recommendedOptimisation = true;
          services.nginx.recommendedProxySettings = true;
          services.nginx.recommendedTlsSettings = true;
          services.nginx.sslProtocols = "TLSv1.3";
          services.nginx.sslCiphers = concatStringsSep ":" [
            "ECDHE-ECDSA-AES256-GCM-SHA384"
            "ECDHE-ECDSA-AES128-GCM-SHA256"
            "ECDHE-ECDSA-CHACHA20-POLY1305"
          ];
          services.nginx.virtualHosts."attest.${config.networking.fqdn}" = {
            enableACME = true;
            forceSSL = true;
            http2 = false;
            locations."/".proxyPass = "http://localhost:3000";
          };
          services.nginx.appendHttpConfig = ''
            proxy_ssl_protocols TLSv1.3;
          '';

          services.openssh.enable = true;
          services.openssh.startWhenNeeded = true;

          services.steward.certFile = pkgs.writeText "steward.crt" (builtins.readFile "${self}/hosts/attest.rvolosatovs.dev/steward.crt");
          services.steward.enable = true;
          services.steward.keyFile = config.sops.secrets.steward-key.path;
          services.steward.log.level = "trace";

          sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

          sops.secrets.steward-key.format = "binary";
          sops.secrets.steward-key.group = config.users.users.steward.group;
          sops.secrets.steward-key.owner = config.users.users.steward.name;
          sops.secrets.steward-key.restartUnits = ["steward.service"];
          sops.secrets.steward-key.sopsFile = "${self}/hosts/attest.rvolosatovs.dev/steward.key";

          systemd.services.steward.serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];

          users.groups.deploy = {};
          users.groups.steward = {};

          users.users.deploy.group = config.users.groups.deploy.name;
          users.users.deploy.isSystemUser = true;
          users.users.deploy.openssh.authorizedKeys.keys = config.users.users.rvolosatovs.openssh.authorizedKeys.keys;
          users.users.deploy.shell = pkgs.bashInteractive;

          users.users.rvolosatovs.isNormalUser = true;
          users.users.rvolosatovs.extraGroups = with config.users.groups; [
            deploy.name
            wheel.name
          ];
          users.users.rvolosatovs.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX"];
          users.users.rvolosatovs.shell = pkgs.zsh;

          users.users.steward.isSystemUser = true;
          users.users.steward.group = config.users.groups.steward.name;

          # Gandi requirement
          systemd.services."getty@tty1" = {
            enable = lib.mkForce true;
            wantedBy = ["multi-user.target"];
            serviceConfig.Restart = "always";
          };

          system.stateVersion = "22.11";

          time.timeZone = "Etc/UTC";
        })
    ];
  }
