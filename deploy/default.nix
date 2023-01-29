{
  self,
  deploy-rs,
  ...
}: let
  mkNode = nixos: {
    hostname = nixos.config.networking.fqdn;
    profiles.system.path = deploy-rs.lib.${nixos.config.nixpkgs.system}.activate.nixos nixos;
    profiles.system.sshUser = "deploy";
    profiles.system.user = "root";
  };
in {
  nodes.rvolosatovs-dev = mkNode self.nixosConfigurations.rvolosatovs-dev;
}
