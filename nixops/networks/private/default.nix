let
  wg.interfaceName = "wg0";
  wg.privateKeyName = "wireguard-${wg.interfaceName}-private";

  wg.hosts.cobalt.ip = "10.0.0.11";
  wg.hosts.cobalt.publicKey = "6L6uG3nflK0GJt1468gV38jWX1BkVIj22XuqXtE99gk=";
  wg.hosts.cobalt.privateKey = builtins.readFile ./../../../vendor/secrets/nixos/hosts/cobalt/wg.private;

  wg.hosts.neon.ip = "10.0.0.10";
  wg.hosts.neon.publicKey = "weyoU0QBHrnjl+2dhibGm5um9+f2sZrg9x8SFd2AVhc=";
  wg.hosts.neon.privateKey = builtins.readFile ./../../../vendor/secrets/nixos/hosts/neon/wg.private;

  wg.hosts.oxygen.ip = "10.0.0.1";
  wg.hosts.oxygen.publicKey = "xjzZIo0SKBNtwP/puZU4cMDdhOsdeMvC/qEKh6RAuAo=";
  wg.hosts.oxygen.privateKey = builtins.readFile ./../../../vendor/secrets/nixos/hosts/oxygen/wg.private;

  wg.hosts.zinc.ip = "10.0.0.30";
  wg.hosts.zinc.publicKey = "QLMUw+yvwXuuEsN06zB+Mj9n/VqD+k4VKa5o2GZrLAk=";

  wg.serverName = "oxygen";
  wg.server = wg.hosts.${wg.serverName};

  wg.hostNames = builtins.attrNames wg.hosts;

  mkVPNNode = lib: {
    networking.hosts = with lib; foldr (name: hosts: mkMerge [
      hosts
      {
        "${wg.hosts.${name}.ip}" = [ "${name}.vpn" ];
      }
    ]) {} wg.hostNames;
  };

  mkVPNBypassRule = ip: ''
    [RoutingPolicyRule]
    To=${ip}
    Table=2468
  '';

  mkVPNClient = lib: name: nodes: with lib; mkMerge [
    (mkVPNNode lib)
    {
      systemd.network.netdevs."30-${wg.interfaceName}" = {
        netdevConfig.Kind = "wireguard";
        netdevConfig.Name = wg.interfaceName;
        extraConfig = ''
          [WireGuard]
          PrivateKey=${wg.hosts.${name}.privateKey}

          [WireGuardPeer]
          PublicKey=${wg.server.publicKey}
          AllowedIPs=0.0.0.0/0, ::/0
          Endpoint=${nodes.${wg.serverName}.config.deployment.targetHost}:${toString nodes.${wg.serverName}.config.networking.wireguard.interfaces.${wg.interfaceName}.listenPort}
          PersistentKeepalive=25
        '';
      };

      systemd.network.networks."30-${wg.interfaceName}" = {
        matchConfig.Name = wg.interfaceName;
        networkConfig.Address = "${wg.hosts.${name}.ip}/32";
        routes = singleton {
          routeConfig.Destination = "0.0.0.0/0";
          routeConfig.Gateway = wg.server.ip;
          routeConfig.GatewayOnLink = "true";
        };
        extraConfig = concatMapStringsSep "\n" mkVPNBypassRule [
          nodes.${wg.serverName}.config.deployment.targetHost
        ];
      };
    }
  ];

  mkNginxTLSProxy = config: name: addr: {
    services.nginx.enable = true;
    services.nginx.virtualHosts."${name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = addr;
      serverName = "${name}.${config.resources.domainName}";
    };
  };

  isLANip = lib: ip: lib.strings.hasPrefix "192.168." ip;
in
  {
    network.description = "Private network of rvolosatovs";
    network.enableRollback = true;

    defaults.networking.firewall.trustedInterfaces = [ wg.interfaceName ];

    cobalt = { config, lib, name, nodes, ... }: {
      imports = [
        ./../../../nixos/hosts/cobalt
        ./../../../vendor/secrets/nixops/hosts/cobalt
        ./../../profiles/laptop
      ];

      config = lib.mkMerge [
        (mkVPNClient lib name nodes)
        {
          deployment.hasFastConnection = true;
        }
      ];
    };

    neon = { config, lib, name, nodes, ... }: {
      imports = [
        ./../../../nixos/hosts/neon
        ./../../../vendor/secrets/nixops/hosts/neon
        ./../../deluge.nix
        ./../../profiles/laptop
      ];

      config = lib.mkMerge [
        (mkVPNClient lib name nodes)
        {
          deployment.hasFastConnection = isLANip lib config.deployment.targetHost;
        }
      ];
    };

    oxygen = { config, lib, name, ... }: {
      imports = [
        ./../../../nixos/hosts/oxygen
        ./../../../nixos/wireguard.server.nix
        ./../../../vendor/secrets/nixops/hosts/oxygen
        ./../../meet.nix
        ./../../miniflux.nix
        ./../../profiles/server
      ];
      
      config = with lib; mkMerge [
        (mkVPNNode lib)
        (mkNginxTLSProxy config "deluge" "http://${wg.hosts.neon.ip}:8112")
        (mkNginxTLSProxy config "jackett" "http://${wg.hosts.neon.ip}:9117")
        (mkNginxTLSProxy config "lidarr" "http://${wg.hosts.neon.ip}:8686")
        (mkNginxTLSProxy config "radarr" "http://${wg.hosts.neon.ip}:7878")
        (mkNginxTLSProxy config "sonarr" "http://${wg.hosts.neon.ip}:8989")
        {
          deployment.hasFastConnection = isLANip lib config.deployment.targetHost;
      
          deployment.keys.${wg.privateKeyName}.text = wg.hosts.${name}.privateKey;
      
          networking.wireguard.interfaces.${wg.interfaceName} = {
            peers = foldr (peerName: peers: peers ++ optional (peerName != name) {
              allowedIPs = [ "${wg.hosts.${peerName}.ip}/32" ];
              publicKey = wg.hosts.${peerName}.publicKey;
            }) [] wg.hostNames;
            privateKeyFile = config.deployment.keys.${wg.privateKeyName}.path;
          };
      
          systemd.services."wireguard-${wg.interfaceName}" = {
            after = [ "${wg.privateKeyName}-key.service" ];
            wants = [ "${wg.privateKeyName}-key.service" ];
          };
        }
      ];
    };
  }
