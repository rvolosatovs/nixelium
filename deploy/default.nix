{
  self,
  deploy-rs,
  ...
}: let
  mkGenericNode = nixos: {
    hostname = nixos.config.networking.fqdn;
    profiles.system.path = deploy-rs.lib.${nixos.config.nixpkgs.system}.activate.nixos nixos;
    profiles.system.sshUser = "deploy";
    profiles.system.user = "root";
  };

  mkTailscaleNode = nixos: {
    hostname = nixos.config.networking.hostName;
    profiles.system.path = deploy-rs.lib.${nixos.config.nixpkgs.system}.activate.nixos nixos;
    profiles.system.sshUser = "deploy";
    profiles.system.user = "root";
  };
in {
  nodes.attest-production1 = mkGenericNode self.nixosConfigurations.attest-production1;
  nodes.attest-production2 = mkGenericNode self.nixosConfigurations.attest-production2;
  nodes.attest-production3 = mkGenericNode self.nixosConfigurations.attest-production3;
  nodes.attest-production4 = mkGenericNode self.nixosConfigurations.attest-production4;

  nodes.attest = mkGenericNode self.nixosConfigurations.attest;
  nodes.attest-staging = mkGenericNode self.nixosConfigurations.attest-staging;
  nodes.attest-testing = mkGenericNode self.nixosConfigurations.attest-testing;
  nodes.benefice-testing = mkGenericNode self.nixosConfigurations.benefice-testing;
  nodes.nuc-1 = mkTailscaleNode self.nixosConfigurations.nuc-1;
  nodes.sgx-equinix-try = mkGenericNode self.nixosConfigurations.sgx-equinix-try;
  nodes.snp-equinix-try = mkGenericNode self.nixosConfigurations.snp-equinix-try;
  nodes.store = mkGenericNode self.nixosConfigurations.store;
  nodes.store-staging = mkGenericNode self.nixosConfigurations.store-staging;
  nodes.store-testing = mkGenericNode self.nixosConfigurations.store-testing;
}
