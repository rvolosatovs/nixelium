{
  self,
  flake-utils,
  nixpkgs,
  ...
}:
with flake-utils.lib.system; let
  infraModules.common = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.common
      self.nixosModules.shells
      self.nixosModules.users
    ];

    environment.systemPackages = with pkgs; [
      curl
      emacs
      nano
      openssl
      tailscale
    ];

    networking.domain = "infra.profian.com";

    networking.firewall.allowedUDPPorts = [config.services.tailscale.port];
    networking.firewall.trustedInterfaces = ["tailscale0"];

    nix.settings.allowed-users = with config.users; [
      "@${groups.wheel.name}"
      users.root.name
    ];
    nix.settings.trusted-users = with config.users; [
      users.root.name
    ];

    profian.users.deploy.enable = true;
    profian.users.haraldh.enable = true;
    profian.users.npmccallum.enable = true;
    profian.users.platten.enable = true;
    profian.users.puiterwijk.enable = true;
    profian.users.rvolosatovs.enable = true;

    programs.neovim.enable = true;

    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = false;

    services.openssh.enable = true;

    services.tailscale.enable = true;
  };

  nuc-1 = nixpkgs.lib.nixosSystem {
    system = x86_64-linux;
    modules = [
      infraModules.common
      {
        imports = [
          "${self}/hosts/nuc-1.infra.profian.com"
        ];

        networking.hostName = "nuc-1";
      }
    ];
  };
in {
  inherit
    nuc-1
    ;
}
