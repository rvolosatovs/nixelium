{
  self,
  flake-utils,
  nixpkgs,
  sops-nix,
  ...
}:
with flake-utils.lib.system; let
  mkInfra = self.lib.hosts.mkHost [
    sops-nix.nixosModules.sops
    ({
      config,
      pkgs,
      ...
    }: {
      environment.systemPackages = with pkgs; [tailscale];

      networking.firewall.allowedUDPPorts = [config.services.tailscale.port];
      networking.firewall.trustedInterfaces = ["tailscale0"];

      services.tailscale.enable = true;
    })
  ];

  nuc-1 = mkInfra x86_64-linux [
    ({...}: {
    })
  ] "nuc-1.infra.profian.com";
in {
  inherit
    nuc-1
    ;
}
