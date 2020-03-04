{ config, lib, ... }:

with lib;

let
  cfg = config.networking.mullvad;
in
  {
    options = {
      networking.mullvad = {
        enable = mkOption {
          example = true;
          default = false;
          type = types.bool;
          description = "Whether to enable Mullvad VPN WireGuard connection.";
        };

        interfaceName = mkOption {
          example = "wg-mullvad";
          default = "wg-mullvad";
          type = types.str;
          description = "WireGuard interface name";
        };

        client.dns = mkOption {
          example = [ "1.1.1.1" ];
          type = with types; listOf str;
          description = "DNS servers to use";
        };

        client.ips = mkOption {
          example = [ "192.168.2.1/24" ];
          default = [];
          type = with types; listOf str;
          description = "The client IP addresses.";
        };

        client.privateKey = mkOption {
          example = "yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=";
          type = types.str;
          description = ''
            Base64 private key.

            This will be copied to /etc/''${interfaceName}-key with 0600 mode and owned by systemd-network user.
          '';
        };

        server.ip = mkOption {
          example = "1.2.3.4";
          type = types.str;
          description = "The server IP address.";
        };

        server.port = mkOption {
          example = 51820;
          default = 51820;
          type = types.int;
          description = "The server port.";
        };

        server.publicKey = mkOption {
          example = "xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=";
          type = types.str;
          description = "Base64 public key of the server.";
        };
      };
    };

    config = mkIf cfg.enable {
      environment.etc."keys/${cfg.interfaceName}" = {
        mode = "0600";
        text = cfg.client.privateKey;
        user = "systemd-network";
      };

      systemd.network.netdevs."30-${cfg.interfaceName}" = {
        netdevConfig.Kind = "wireguard";
        netdevConfig.Name = cfg.interfaceName;
        wireguardConfig.PrivateKeyFile = "/etc/${config.environment.etc."keys/${cfg.interfaceName}".target}";
        wireguardPeers = singleton {
          wireguardPeerConfig.PublicKey = cfg.server.publicKey;
          wireguardPeerConfig.AllowedIPs = [ "0.0.0.0/0" "::0/0" ];
          wireguardPeerConfig.Endpoint = "${cfg.server.ip}:${toString cfg.server.port}";
        };
      };

      systemd.network.networks."30-${cfg.interfaceName}" = {
        address = cfg.client.ips;
        dns = cfg.client.dns;
        name = cfg.interfaceName;
        routes = [
          {
            routeConfig.Destination = "0.0.0.0/0";
          }
          {
            routeConfig.Destination = "::/0";
          }
        ];
        extraConfig = ''
          [RoutingPolicyRule]
          To=${cfg.server.ip}
          Table=2468
        '';
      };
    };
  }
