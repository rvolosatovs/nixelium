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
  ] "infra.profian.com" "nuc-1";
in {
  inherit
    nuc-1
    ;
}
