let
  wg.neon.publicKey = "weyoU0QBHrnjl+2dhibGm5um9+f2sZrg9x8SFd2AVhc=";
  wg.oxygen.publicKey = "xjzZIo0SKBNtwP/puZU4cMDdhOsdeMvC/qEKh6RAuAo=";

  wg.privateKeyName = "wireguard-wg0-private";

  resources.wireguard.port = 51820;
in
  rec {
    neon = { config, pkgs, ... }: {
      imports = [
        ./../../../nixos/hosts/neon
        ./../../../vendor/secrets/nixops/hosts/neon
        ./../../profiles/laptop
      ];
      deployment.keys.${wg.privateKeyName}.text = builtins.readFile ./../../../vendor/secrets/nixos/hosts/neon/wg.private;
      networking.wireguard.interfaces.wg0.allowedIPsAsRoutes = false;
      networking.wireguard.interfaces.wg0.ips = [ "10.0.0.2/24" ];
      networking.wireguard.interfaces.wg0.privateKeyFile = config.deployment.keys.${wg.privateKeyName}.path;
      networking.wireguard.interfaces.wg0.peers = [{
        inherit (wg.oxygen) publicKey;
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = "oxygen:${toString resources.wireguard.port}";
        persistentKeepalive = 25;
      }];
      networking.wireguard.interfaces.wg0.postSetup = ''
        ${pkgs.iproute}/bin/ip route add $(${pkgs.iproute}/bin/ip route get "$(${pkgs.wireguard}/bin/wg show wg0 endpoints | sed -n 's/.*\t\(.*\):.*/\1/p')" | sed '/ via [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/{s/^\(.* via [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/}' | head -n 1) 2>/dev/null || true
        ${pkgs.iproute}/bin/ip route add default via 10.0.0.1 dev wg0
      '';
      systemd.services.wireguard-wg0.after = [ "${wg.privateKeyName}-key.service" "NetworkManager-wait-online.service" ];
      systemd.services.wireguard-wg0.wants = [ "${wg.privateKeyName}-key.service" "NetworkManager-wait-online.service" ];
    };

    oxygen = { config, ... }: {
      imports = [
        ./../../../nixos/hosts/oxygen
        ./../../../vendor/secrets/nixops/hosts/oxygen
        ./../../meet.nix
        ./../../profiles/server
      ];
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
      boot.kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 1;
      deployment.keys.${wg.privateKeyName}.text = builtins.readFile ./../../../vendor/secrets/nixos/hosts/oxygen/wg.private;
      networking.firewall.allowedUDPPorts = [
        resources.wireguard.port
      ];
      networking.wireguard.interfaces.wg0.ips = [ "10.0.0.1/24" ];
      networking.wireguard.interfaces.wg0.listenPort = resources.wireguard.port;
      networking.wireguard.interfaces.wg0.privateKeyFile = config.deployment.keys.${wg.privateKeyName}.path;
      networking.wireguard.interfaces.wg0.peers = [{
        inherit (wg.neon) publicKey;
        allowedIPs = [ "10.0.0.2/32" ];
      }];
      systemd.services.wireguard-wg0.after = [ "${wg.privateKeyName}-key.service" ];
      systemd.services.wireguard-wg0.wants = [ "${wg.privateKeyName}-key.service" ];
    };

    network.description = "Private network of rvolosatovs";
    network.enableRollback = true;
  }
