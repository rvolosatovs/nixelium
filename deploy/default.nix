{
  self,
  deploy-rs,
  ...
}: let
  mkDeployNode = nixos: {
    hostname = nixos.config.networking.fqdn;
    profiles.system.path = deploy-rs.lib.${nixos.config.nixpkgs.system}.activate.nixos nixos;
    profiles.system.sshUser = "deploy";
    profiles.system.user = "root";
  };
in {
  nodes.attest = mkDeployNode self.nixosConfigurations.attest;
  nodes.attest-staging = mkDeployNode self.nixosConfigurations.attest-staging;
  nodes.attest-testing = mkDeployNode self.nixosConfigurations.attest-testing;
  nodes.sgx-equinix-try = mkDeployNode self.nixosConfigurations.sgx-equinix-try;
  nodes.snp-equinix-try = mkDeployNode self.nixosConfigurations.snp-equinix-try;
  nodes.store = mkDeployNode self.nixosConfigurations.store;
  nodes.store-staging = mkDeployNode self.nixosConfigurations.store-staging;
  nodes.store-testing = mkDeployNode self.nixosConfigurations.store-testing;
}
