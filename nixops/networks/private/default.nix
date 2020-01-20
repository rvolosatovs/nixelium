let
  wg.neon.ip = "10.0.0.10/32";
  wg.neon.publicKey = "weyoU0QBHrnjl+2dhibGm5um9+f2sZrg9x8SFd2AVhc=";

  wg.cobalt.ip = "10.0.0.11/32";
  wg.cobalt.publicKey = "6L6uG3nflK0GJt1468gV38jWX1BkVIj22XuqXtE99gk=";

  wg.zinc.ip = "10.0.0.30/32";
  wg.zinc.publicKey = "QLMUw+yvwXuuEsN06zB+Mj9n/VqD+k4VKa5o2GZrLAk=";

  wg.oxygen.publicKey = "xjzZIo0SKBNtwP/puZU4cMDdhOsdeMvC/qEKh6RAuAo=";

  wg.privateKeyName = "wireguard-wg0-private";

  mkVPNBypassRule = ip: ''
    [RoutingPolicyRule]
    To=${ip}
    Table=2468
  '';

  isLANip = pkgs: ip: pkgs.lib.strings.hasPrefix "192.168." ip;
in
  {
    cobalt = { config, pkgs, ... }: {
      imports = [
        ./../../../nixos/hosts/cobalt
        ./../../../vendor/secrets/nixops/hosts/cobalt
        ./../../profiles/laptop
      ];

      systemd.network.netdevs."30-wg0" = {
        netdevConfig.Kind = "wireguard";
        netdevConfig.Name = "wg0";
        extraConfig = ''
          [WireGuard]
          PrivateKey=${builtins.readFile ./../../../vendor/secrets/nixos/hosts/cobalt/wg.private}

          [WireGuardPeer]
          PublicKey=${wg.oxygen.publicKey}
          AllowedIPs=0.0.0.0/0, ::/0
          Endpoint=${config.resources.wireguard.serverIP}:${toString config.resources.wireguard.port}
          PersistentKeepalive=25
        '';
      };

      systemd.network.networks."30-wg0" = {
        matchConfig.Name = "wg0";
        networkConfig.Address = wg.cobalt.ip;
        routes = pkgs.lib.singleton {
          routeConfig.Destination = "0.0.0.0/0";
          routeConfig.Gateway = "10.0.0.1";
          routeConfig.GatewayOnLink = "true";
        };
        extraConfig = pkgs.lib.concatMapStringsSep "\n" mkVPNBypassRule [ 
          config.resources.wireguard.serverIP
          "37.244.32.0/19" # Blizzard EU
        ];
      };
    };

    neon = { config, pkgs, ... }: {
      imports = [
        ./../../../nixos/hosts/neon
        ./../../../vendor/secrets/nixops/hosts/neon
        ./../../profiles/laptop
      ];

      deployment.hasFastConnection = isLANip pkgs config.deployment.targetHost;

      systemd.network.netdevs."30-wg0" = {
        netdevConfig.Kind = "wireguard";
        netdevConfig.Name = "wg0";
        extraConfig = ''
          [WireGuard]
          PrivateKey=${builtins.readFile ./../../../vendor/secrets/nixos/hosts/neon/wg.private}

          [WireGuardPeer]
          PublicKey=${wg.oxygen.publicKey}
          AllowedIPs=0.0.0.0/0, ::/0
          Endpoint=${config.resources.wireguard.serverIP}:${toString config.resources.wireguard.port}
          PersistentKeepalive=25
        '';
      };

      systemd.network.networks."30-wg0" = {
        matchConfig.Name = "wg0";
        networkConfig.Address = wg.neon.ip;
        routes = pkgs.lib.singleton {
          routeConfig.Destination = "0.0.0.0/0";
          routeConfig.Gateway = "10.0.0.1";
          routeConfig.GatewayOnLink = "true";
        };
        extraConfig = pkgs.lib.concatMapStringsSep "\n" mkVPNBypassRule [ 
          config.resources.wireguard.serverIP
        ];
      };
    };

    oxygen = { config, pkgs, ... }: rec {
      imports = [
        ./../../../nixos/hosts/oxygen
        ./../../../nixos/wireguard.server.nix
        ./../../../vendor/secrets/nixops/hosts/oxygen
        ./../../meet.nix
        ./../../miniflux.nix
        ./../../profiles/server
      ];

      deployment.hasFastConnection = isLANip pkgs config.deployment.targetHost;
      deployment.keys.${wg.privateKeyName}.text = builtins.readFile ./../../../vendor/secrets/nixos/hosts/oxygen/wg.private;

      networking.wireguard.interfaces.wg0.privateKeyFile = config.deployment.keys.${wg.privateKeyName}.path;
      networking.wireguard.interfaces.wg0.peers = [
        {
          inherit (wg.neon) publicKey;
          allowedIPs = [ wg.neon.ip ];
        }
        {
          inherit (wg.cobalt) publicKey;
          allowedIPs = [ wg.cobalt.ip ];
        }
        {
          inherit (wg.zinc) publicKey;
          allowedIPs = [ wg.zinc.ip ];
        }
      ];

      systemd.services.wireguard-wg0.after = [ "${wg.privateKeyName}-key.service" ];
      systemd.services.wireguard-wg0.wants = [ "${wg.privateKeyName}-key.service" ];
    };

    network.description = "Private network of rvolosatovs";
    network.enableRollback = true;
  }
