{
  self,
  flake-utils,
  sops-nix,
  ...
}:
with flake-utils.lib.system; let
  mkSteward = self.lib.hosts.mkService [
    sops-nix.nixosModules.sops
    ({
      config,
      pkgs,
      ...
    }: {
      services.steward.certFile = pkgs.writeText "steward.crt" (builtins.readFile "${self}/hosts/${config.networking.fqdn}/steward.crt");
      services.steward.enable = true;
      services.steward.keyFile = config.sops.secrets.key.path;

      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      sops.secrets.key.format = "binary";
      sops.secrets.key.mode = "0000";
      sops.secrets.key.restartUnits = ["steward.service"];
      sops.secrets.key.sopsFile = "${self}/hosts/${config.networking.fqdn}/steward.key";

      systemd.services.steward = self.lib.systemd.withSecret config pkgs "steward" "key";

      # Workaround for https://github.com/profianinc/infrastructure/issues/109

      users.groups.steward = {};

      users.users.steward.isSystemUser = true;
      users.users.steward.group = config.users.groups.steward.name;
    })
  ];

  attest-testing = mkSteward x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/nixosModules/ci.nix"
      ];

      services.steward.log.level = "debug";
      services.steward.package = pkgs.steward.testing;
    })
  ] "testing.profian.com" "attest";

  attest-staging = mkSteward x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/nixosModules/ci.nix"
      ];

      services.steward.log.level = "info";
      services.steward.package = pkgs.steward.staging;
    })
  ] "staging.profian.com" "attest";

  attest = mkSteward x86_64-linux [
    ({pkgs, ...}: {
      services.steward.package = pkgs.steward.production;
    })
  ] "profian.com" "attest";
in {
  inherit
    attest
    attest-staging
    attest-testing
    ;
}
