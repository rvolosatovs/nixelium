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
  nodes.sgx-equinix-demo = mkDeployNode self.nixosConfigurations.sgx-equinix-demo;
  nodes.snp-equinix-demo = mkDeployNode self.nixosConfigurations.snp-equinix-demo;
  nodes.store = mkDeployNode self.nixosConfigurations.store;
  nodes.store-staging = mkDeployNode self.nixosConfigurations.store-staging;
  nodes.store-testing = mkDeployNode self.nixosConfigurations.store-testing;
}
