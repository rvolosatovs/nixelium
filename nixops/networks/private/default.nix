let
  lib = import (./../../lib);

  wg.neon.publicKey = "weyoU0QBHrnjl+2dhibGm5um9+f2sZrg9x8SFd2AVhc=";
  wg.oxygen.publicKey = "xjzZIo0SKBNtwP/puZU4cMDdhOsdeMvC/qEKh6RAuAo=";

  #wgNetwork = lib.mkWireguardNetwork {
    #peers.neon.publicKey
    #peers.oxygen.
    #serverName = "oxygen";
  #};
in
  rec {
    neon.imports = [
      ./../../../nixos/hosts/neon
      #./../../../nixos/wireguard.client.nix
      ./../../../vendor/secrets/nixops/hosts/neon
      ./../../profiles/laptop
    ];
    #neon.networking.wireguard.interfaces.wg0.peers = [{
      #publicKey = oxygen.networking.wireguard.interfaces.wg0.publicKey;
      #allowedIPs = [ "10.0.0.0/24" ];
      #persistentKeepalive = 25;
    #}];

    oxygen.imports = [
      ./../../../nixos/hosts/oxygen
      #./../../../nixos/wireguard.server.nix
      ./../../../vendor/secrets/nixops/hosts/oxygen
      ./../../meet.nix
      ./../../profiles/server
    ];
    #oxygen.deployment.keys."wireguard-wg0-private".text = builtins.readFile ./../vendor/secrets/nixos/hosts/oxygen/wg.private;
    #oxygen.networking.wireguard.interfaces.wg0.peers = [
      #{
        #allowedIPs = neon.networking.wireguard.interfaces.wg0.ips;
        #inherit (wg.neon) publicKey;
      #}
      ##{
        ##allowedIPs = argon.networking.wireguard.interfaces.wg0.ips;
        ##inherit (wg.argon) publicKey;
      ##}
    #];

    network.description = "Private network of rvolosatovs";
    network.enableRollback = true;
  }
