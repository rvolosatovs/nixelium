{
  self,
  flake-utils,
  sops-nix,
  ...
}:
with flake-utils.lib.system; let
  mkBenefice = self.lib.hosts.mkService [
    sops-nix.nixosModules.sops
    ({
      config,
      lib,
      pkgs,
      ...
    }: {
      networking.firewall.enable = lib.mkForce false;

      services.benefice.enable = true;
      services.benefice.oidc.secretFile = config.sops.secrets.oidc-secret.path;

      services.enarx.enable = true;

      services.nginx.clientMaxBodySize = "100m";
      services.nginx.appendHttpConfig = ''
        add_header Strict-Transport-Security "max-age=0";
      '';

      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      sops.secrets.oidc-secret.format = "binary";
      sops.secrets.oidc-secret.mode = "0000";
      sops.secrets.oidc-secret.restartUnits = ["benefice.service"];
      sops.secrets.oidc-secret.sopsFile = "${self}/hosts/${config.networking.fqdn}/oidc-secret";

      systemd.services.benefice = self.lib.systemd.withSecret config pkgs "benefice" "oidc-secret";

      # Workaround for https://github.com/profianinc/infrastructure/issues/109

      users.groups.benefice = {};

      users.users.benefice.isSystemUser = true;
      users.users.benefice.group = config.users.groups.benefice.name;
    })
  ];

  benefice-testing = mkBenefice x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/hosts/benefice.testing.profian.com"
        "${self}/nixosModules/ci.nix"
      ];

      services.benefice.log.level = "debug";
      services.benefice.oidc.client = "FTmeUMamlu8HRs11mvtmmZHnmCwRIo8E";
      services.benefice.package = pkgs.benefice.testing;
    })
  ];

  sgx-equinix-try = mkBenefice x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/hosts/sgx.equinix.try.enarx.dev"
      ];

      services.benefice.log.level = "info";
      services.benefice.oidc.client = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
      services.benefice.package = pkgs.benefice.staging;
    })
  ];

  snp-equinix-try = mkBenefice x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/hosts/snp.equinix.try.enarx.dev"
      ];

      services.benefice.log.level = "info";
      services.benefice.oidc.client = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";
      services.benefice.package = pkgs.benefice.staging;
    })
  ];
in {
  inherit
    benefice-testing
    sgx-equinix-try
    snp-equinix-try
    ;
}
