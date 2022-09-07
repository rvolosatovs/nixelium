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
  nodes.attest-production-1 = mkGenericNode self.nixosConfigurations.attest-production-1;
  nodes.attest-production-2 = mkGenericNode self.nixosConfigurations.attest-production-2;
  nodes.attest-production-3 = mkGenericNode self.nixosConfigurations.attest-production-3;
  nodes.attest-production-4 = mkGenericNode self.nixosConfigurations.attest-production-4;

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
