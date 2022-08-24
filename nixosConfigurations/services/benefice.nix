{
  self,
  enarx,
  flake-utils,
  ...
}:
with flake-utils.lib.system; let
  mkBenefice = self.lib.hosts.mkService [
    ({
      config,
      lib,
      pkgs,
      ...
    }: let
      enarx-oci = enarx.packages.x86_64-linux.enarx-x86_64-unknown-linux-musl-oci;
    in {
      environment.systemPackages = [pkgs.enarx];

      networking.firewall.enable = lib.mkForce false;

      services.benefice.enable = true;
      services.benefice.enarx.backend = config.services.enarx.backend;
      services.benefice.oci.backend = "docker";
      services.benefice.oci.image = "${enarx-oci.imageName}:${enarx-oci.imageTag}";
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

      systemd.services.load-enarx-image.script = "${pkgs.docker}/bin/docker load < ${enarx-oci}";
      systemd.services.load-enarx-image.serviceConfig.Type = "oneshot";
      systemd.services.load-enarx-image.serviceConfig.DynamicUser = true;
      systemd.services.load-enarx-image.serviceConfig.SupplementaryGroups = with config.users.groups; [docker.name];
      systemd.services.load-enarx-image.wantedBy = ["multi-user.target"];

      # Workaround for https://github.com/profianinc/infrastructure/issues/109
      users.groups.benefice = {};

      # NOTE: This is essentially equal to giving `benefice` user `root` access, which is a terrible idea.
      # Ideally, we should use podman instead (see `virtualisation.podman.*`)
      # Alternatively, we could explore `virtualisation.docker.rootless.*`
      # Ideally, we should also split Benefice into a producer and consumer,
      # which communicate via a message queue like a Redis 6 stream.
      users.users.benefice.extraGroups = with config.users.groups; [docker.name];
      users.users.benefice.group = config.users.groups.benefice.name;
      users.users.benefice.isSystemUser = true;

      # TODO: Introduce a `users` NixOS module with `adminGroups` option, to which `docker.name` should be added
      users.users.haraldh.extraGroups = with config.users.groups; [docker.name];
      users.users.npmccallum.extraGroups = with config.users.groups; [docker.name];
      users.users.platten.extraGroups = with config.users.groups; [docker.name];
      users.users.puiterwijk.extraGroups = with config.users.groups; [docker.name];
      users.users.rvolosatovs.extraGroups = with config.users.groups; [docker.name];

      virtualisation.docker.enable = true;
      virtualisation.docker.autoPrune.enable = true;
    })
  ];

  benefice-testing = mkBenefice x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/nixosModules/ci.nix"
      ];

      services.benefice.log.level = "debug";
      services.benefice.oidc.client = "FTmeUMamlu8HRs11mvtmmZHnmCwRIo8E";
      services.benefice.package = pkgs.benefice.testing;
    })
  ] "testing.profian.com" "benefice";

  sgx-equinix-try = mkBenefice x86_64-linux [
    ({pkgs, ...}: {
      services.benefice.log.level = "info";
      services.benefice.oidc.client = "23Lt09AjF8HpUeCCwlfhuV34e2dKD1MH";
      services.benefice.package = pkgs.benefice.staging;
    })
  ] "equinix.try.enarx.dev" "sgx";

  snp-equinix-try = mkBenefice x86_64-linux [
    ({pkgs, ...}: {
      imports = [
        "${self}/hosts/snp.equinix.try.enarx.dev"
      ];

      services.benefice.log.level = "info";
      services.benefice.oidc.client = "Ayrct2YbMF6OHFN8bzpv3XemWI3ca5Hk";
      services.benefice.package = pkgs.benefice.staging;
    })
  ] "equinix.try.enarx.dev" "snp";
in {
  inherit
    benefice-testing
    sgx-equinix-try
    snp-equinix-try
    ;
}
