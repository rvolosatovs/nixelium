let
  wg.neon.publicKey = "weyoU0QBHrnjl+2dhibGm5um9+f2sZrg9x8SFd2AVhc=";
  wg.oxygen.publicKey = "xjzZIo0SKBNtwP/puZU4cMDdhOsdeMvC/qEKh6RAuAo=";
  wg.zinc.publicKey = "QLMUw+yvwXuuEsN06zB+Mj9n/VqD+k4VKa5o2GZrLAk=";

  wg.mamaphone.publicKey = "x11PkoJ4uU5RC/OQnFJ8kTlQ8YiGjJBQKe6hUpRIRkk=";
  wg.papaphone.publicKey = "KMHARoY2eeQhn4iTlecwBDYjoCUIsEaOaPgyGfcI4XU=";
  wg.papatablet.publicKey = "9Egkv/9PqDhEpOiZWq4dI0zbq4Y1PCYjiqxDp2vbC0Y=";

  wg.privateKeyName = "wireguard-wg0-private";
in
  rec {
    neon = { config, pkgs, ... }: {
      imports = [
        ./../../../nixos/hosts/neon
        ./../../../vendor/secrets/nixops/hosts/neon
        ./../../profiles/laptop
      ];

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
        networkConfig.Address = "10.0.0.2/32";
        routes = [
           {
             routeConfig.Destination = "0.0.0.0/0";
             routeConfig.Gateway = "10.0.0.1";
             routeConfig.GatewayOnlink = "true";
           }
        ];
        extraConfig = ''
          [RoutingPolicyRule]
          To=${config.resources.wireguard.serverIP}
          Table=2468
        '';
      };
    };

    oxygen = { config, ... }: {
      imports = [
        ./../../../nixos/hosts/oxygen
        ./../../../nixos/wireguard.server.nix
        ./../../../vendor/secrets/nixops/hosts/oxygen
        ./../../meet.nix
        ./../../profiles/server
      ];
      deployment.keys.${wg.privateKeyName}.text = builtins.readFile ./../../../vendor/secrets/nixos/hosts/oxygen/wg.private;

      networking.wireguard.interfaces.wg0.privateKeyFile = config.deployment.keys.${wg.privateKeyName}.path;
      networking.wireguard.interfaces.wg0.peers = [
        {
          inherit (wg.neon) publicKey;
          allowedIPs = [ "10.0.0.2/32" ];
        }
        {
          inherit (wg.zinc) publicKey;
          allowedIPs = [ "10.0.0.12/32" ];
        }
        {
          inherit (wg.papaphone) publicKey;
          allowedIPs = [ "10.0.0.40/32" ];
        }
        {
          inherit (wg.mamaphone) publicKey;
          allowedIPs = [ "10.0.0.41/32" ];
        }
        {
          inherit (wg.papatablet) publicKey;
          allowedIPs = [ "10.0.0.42/32" ];
        }
      ];

      systemd.services.wireguard-wg0.after = [ "${wg.privateKeyName}-key.service" ];
      systemd.services.wireguard-wg0.wants = [ "${wg.privateKeyName}-key.service" ];
    };

    network.description = "Private network of rvolosatovs";
    network.enableRollback = true;
  }
