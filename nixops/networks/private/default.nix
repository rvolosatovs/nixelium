let
  wg.neon.publicKey = "weyoU0QBHrnjl+2dhibGm5um9+f2sZrg9x8SFd2AVhc=";
  wg.oxygen.publicKey = "xjzZIo0SKBNtwP/puZU4cMDdhOsdeMvC/qEKh6RAuAo=";
  wg.zinc.publicKey = "QLMUw+yvwXuuEsN06zB+Mj9n/VqD+k4VKa5o2GZrLAk=";

  wg.privateKeyName = "wireguard-wg0-private";

  resources.wireguard.port = 51820; # TODO: Fix imports in NixOps
in
  rec {
    neon = { config, pkgs, ... }: {
      imports = [
        ./../../../nixos/hosts/neon
        ./../../../nixos/wireguard.client.nix
        ./../../../vendor/secrets/nixops/hosts/neon
        ./../../profiles/laptop
      ];
      deployment.keys.${wg.privateKeyName}.text = builtins.readFile ./../../../vendor/secrets/nixos/hosts/neon/wg.private;

      networking.wireguard.interfaces.wg0.ips = [ "10.0.0.2/24" ];
      networking.wireguard.interfaces.wg0.privateKeyFile = config.deployment.keys.${wg.privateKeyName}.path;
      networking.wireguard.interfaces.wg0.peers = [{
        inherit (wg.oxygen) publicKey;
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "oxygen:${toString resources.wireguard.port}";
        persistentKeepalive = 25;
      }];

      systemd.services.wireguard-wg0.after = [ "${wg.privateKeyName}-key.service" ];
      systemd.services.wireguard-wg0.wants = [ "${wg.privateKeyName}-key.service" ];
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

      networking.nat.externalInterface = "eth0";

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
      ];

      systemd.services.wireguard-wg0.after = [ "${wg.privateKeyName}-key.service" ];
      systemd.services.wireguard-wg0.wants = [ "${wg.privateKeyName}-key.service" ];
    };

    network.description = "Private network of rvolosatovs";
    network.enableRollback = true;
  }
