{
  self,
  flake-utils,
  nixpkgs,
  ...
}:
with flake-utils.lib.system; let
  mkInfra = self.lib.hosts.mkHost [
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
