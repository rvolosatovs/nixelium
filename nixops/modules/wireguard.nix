{
  config,
  pkgs,
  lib,
  name,
  nodes,
  ...
}:
with lib; let
  cfg = config.network.wireguard;

  netdevName = "30-${cfg.interfaceName}";
  networkName = "30-${cfg.interfaceName}";
  serviceName = "wireguard-${cfg.interfaceName}";

  privateKeyName = "wireguard-${cfg.interfaceName}-private";

  serverNode = nodes."${cfg.server.name}";

  # TODO: Extract this into a generic function.
  mkSecretPath = name:
    if config.deployment.storeKeysOnMachine
    then "/etc/${config.environment.etc."keys/${name}".target}"
    else config.deployment.keys.${name}.path;

  peerOptions = {
    ip = mkOption {
      example = "10.0.0.2";
      type = types.str;
      description = "WireGuard peer IP address.";
    };

    publicKey = mkOption {
      example = "yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=";
      type = types.str;
      description = "Base64 public key.";
    };
  };
in {
  options = {
    network.wireguard = {
      inherit (peerOptions) ip publicKey;

      enable = mkOption {
        example = true;
        default = false;
        type = types.bool;
        description = "Whether to enable VPN WireGuard connection between hosts in the network.";
      };

      interfaceName = mkOption {
        example = "wg-private";
        type = types.str;
        description = "WireGuard interface name";
      };

      subnet = mkOption {
        example = "10.0.0.0/24";
        type = types.str;
        description = "WireGuard subnet.";
      };

      privateKey = mkOption {
        type = types.str;
        description = "Base64 private key.";
      };

      dns = mkOption {
        example = ["1.1.1.1"];
        default = null;
        type = with types; nullOr (listOf str);
        description = "DNS servers to use";
      };

      extraPeers = mkOption {
        default = {};
        type = types.attrsOf (types.submodule ({name, ...}: {
          options = peerOptions;
        }));
      };

      server.name = mkOption {
        example = "wg-server";
        type = types.str;
        description = "WireGuard server name";
      };

      server.port = mkOption {
        example = 51820;
        default = 51820;
        type = types.int;
        description = "WireGuard server port.";
      };
    };
  };

  config = let
    peers =
      foldr
      (peerName: peers:
        assert lib.asserts.assertMsg (! peers ? peerName) "duplicate peer '${peerName}'";
          peers
          // {
            "${peerName}" = {
              inherit (nodes."${peerName}".config.network.wireguard) ip publicKey;
            };
          })
      cfg.extraPeers
      (attrNames nodes);
  in
    mkIf cfg.enable (mkMerge [
      {
        environment.systemPackages = [pkgs.wireguard-tools];

        networking.firewall.trustedInterfaces = [cfg.interfaceName];

        networking.hosts =
          mapAttrs'
          (
            name: peer:
              nameValuePair peer.ip ["${name}.vpn"]
          )
          peers;

        systemd.network.netdevs."${netdevName}" = {
          netdevConfig.Kind = "wireguard";
          netdevConfig.Name = cfg.interfaceName;
          wireguardConfig.FirewallMark = 2;
          wireguardConfig.PrivateKeyFile = mkSecretPath privateKeyName;
        };
        systemd.network.networks."${networkName}" = {
          address = ["${cfg.ip}/32"];
          name = cfg.interfaceName;
        };
      }

      (mkIf (cfg.dns != null) {
        systemd.network.networks."${networkName}".dns = cfg.dns;
      })

      # Server
      (mkIf (name == cfg.server.name) {
        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
        boot.kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 1;
        boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = 2;

        networking.nat.enable = true;
        networking.nat.internalInterfaces = [cfg.interfaceName];

        networking.firewall.allowedUDPPorts = [cfg.server.port];

        systemd.network.netdevs."${netdevName}" = {
          wireguardConfig.ListenPort = cfg.server.port;
          wireguardPeers =
            mapAttrsToList
            (peerName: peer: {
              wireguardPeerConfig.AllowedIPs = ["${peer.ip}/32"];
              wireguardPeerConfig.PersistentKeepalive = 25;
              wireguardPeerConfig.PublicKey = peer.publicKey;
            })
            (filterAttrs (peerName: _: peerName != name) peers);
        };

        systemd.network.networks."${networkName}" = {
          routes = [
            {
              routeConfig.Destination = cfg.subnet;
              routeConfig.Gateway = cfg.ip;
            }
          ];
        };
      })

      # Client
      (mkIf (name != cfg.server.name) {
        systemd.network.netdevs."${netdevName}".wireguardPeers = [
          {
            wireguardPeerConfig.AllowedIPs = ["0.0.0.0/0" "::0/0"];
            wireguardPeerConfig.Endpoint = "${serverNode.config.networking.publicIPv4}:${toString cfg.server.port}";
            wireguardPeerConfig.PersistentKeepalive = 25;
            wireguardPeerConfig.PublicKey = serverNode.config.network.wireguard.publicKey;
          }
        ];

        systemd.network.networks."${networkName}" = {
          routes = [
            {
              routeConfig.Destination = cfg.subnet;
              routeConfig.Gateway = serverNode.config.network.wireguard.ip;
              routeConfig.GatewayOnLink = true;
              routeConfig.Metric = 512;
            }
          ];
        };
      })

      (mkIf config.deployment.storeKeysOnMachine {
        environment.etc."keys/${privateKeyName}" = {
          mode = "0600";
          text = cfg.privateKey;
          user = "systemd-network";
        };
      })

      (mkIf (!config.deployment.storeKeysOnMachine) {
        deployment.keys."${privateKeyName}" = {
          text = cfg.privateKey;
          user = "systemd-network";
        };
        systemd.services."${serviceName}" = {
          after = ["${privateKeyName}-key.service"];
          wants = ["${privateKeyName}-key.service"];
        };
        users.users.systemd-network.extraGroups = ["keys"];
      })
    ]);
}
