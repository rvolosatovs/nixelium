{ pkgs, ... }:
{
  networking.networkmanager.dns = "dnsmasq";
  networking.networkmanager.unmanaged = [ "wg0" ];

  networking.wireguard.interfaces.wg0.allowedIPsAsRoutes = false;

  networking.wireguard.interfaces.wg0.postSetup = ''
    ${pkgs.iproute}/bin/ip route add $(${pkgs.iproute}/bin/ip route get "$(${pkgs.wireguard}/bin/wg show wg0 endpoints | sed -n 's/.*\t\(.*\):.*/\1/p')" | sed '/ via [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/{s/^\(.* via [0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1/}' | head -n 1) 2>/dev/null || true
    ${pkgs.iproute}/bin/ip route add default via 10.0.0.1 dev wg0
  '';

  systemd.services.wireguard-wg0.after = [ "NetworkManager-wait-online.service" ];
  systemd.services.wireguard-wg0.wants = [ "NetworkManager-wait-online.service" ];
}
