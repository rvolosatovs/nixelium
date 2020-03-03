{ config, lib, name, nodes, ... }:

with lib;

let
  cfg = config.network.wireguard;

  netdevName = "30-${cfg.interfaceName}";
  networkName = "30-${cfg.interfaceName}";
  serviceName = "wireguard-${cfg.interfaceName}";

  privateKeyName = "wireguard-${cfg.interfaceName}-private";

  peerNames = attrNames nodes;
  serverNode = nodes."${cfg.server.name}";
in
  {
    # TODO: Support custom hosts.
    options = {
      network.wireguard = {
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

        ip = mkOption {
          example = "10.0.0.2";
          type = types.str;
          description = "WireGuard peer IP address.";
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

        publicKey = mkOption {
          example = "yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=";
          type = types.str;
          description = "Base64 public key.";
        };

        dns = mkOption {
          example = [ "1.1.1.1" ];
          default = null;
          type = with types; nullOr (listOf str);
          description = "DNS servers to use";
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

    config = mkIf cfg.enable (mkMerge [
      {
        deployment.keys."${privateKeyName}" = {
          text = cfg.privateKey;
          user = "systemd-network";
        };

        networking.firewall.trustedInterfaces = [ cfg.interfaceName ];

        networking.hosts = foldr (peerName: hosts: mkMerge [
          hosts
          {
            "${nodes."${peerName}".config.network.wireguard.ip}" = [ "${peerName}.vpn" ];
          }
        ]) {} peerNames;

        systemd.network.netdevs."${netdevName}" = {
          netdevConfig.Kind = "wireguard";
          netdevConfig.Name = cfg.interfaceName;
          wireguardConfig.PrivateKeyFile = config.deployment.keys."${privateKeyName}".path;
        };

        systemd.network.networks."${networkName}" = {
          address = [ "${cfg.ip}/32" ];
          name = cfg.interfaceName;
        };

        systemd.services."${serviceName}" = {
          after = [ "${privateKeyName}-key.service" ];
          wants = [ "${privateKeyName}-key.service" ];
        };

        users.users.systemd-network.extraGroups = [ "keys" ];
      }

      (mkIf (cfg.dns != null) {
        systemd.network.networks."${networkName}".dns = cfg.dns;
      })

      (mkIf (name == cfg.server.name) {
        # Server
        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
        boot.kernel.sysctl."net.ipv4.conf.all.proxy_arp" = 1;

        networking.nat.enable = true;
        networking.nat.internalInterfaces = [ cfg.interfaceName ];

        networking.firewall.allowedUDPPorts = [ cfg.server.port ];

        systemd.network.netdevs."${netdevName}" = {
          wireguardConfig.ListenPort = cfg.server.port;
          wireguardPeers = foldr (peerName: peers: peers ++ optional (peerName != name) {
            wireguardPeerConfig.AllowedIPs = [ "${nodes."${peerName}".config.network.wireguard.ip}/32" ];
            wireguardPeerConfig.PersistentKeepalive = 25;
            wireguardPeerConfig.PublicKey = nodes."${peerName}".config.network.wireguard.publicKey;
          }) [] peerNames;
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

      (mkIf (name != cfg.server.name) {
        # Client
        systemd.network.netdevs."${netdevName}".wireguardPeers = [
          {
            wireguardPeerConfig.AllowedIPs = [ "0.0.0.0/0" "::0/0" ];
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
            }
          ];
        };
      })
    ]);
  }
