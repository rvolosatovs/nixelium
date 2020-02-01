{ ... }:
{
  networking.hosts."192.168.188.10" = [ "neon.lan" "neon.eth.lan" ];
  networking.hosts."192.168.188.11" = [ "cobalt.lan" "cobalt.eth.lan" ];

  networking.hosts."192.168.188.20" = [ "neon.wifi.lan" ];
  networking.hosts."192.168.188.21" = [ "cobalt.wifi.lan" ];

  networking.hosts."192.168.188.30" = [ "zinc.lan" "zinc.wifi.lan" ];

  networking.hosts."192.168.188.50" = [ "rocky.lan" ];
  networking.hosts."192.168.188.51" = [ "quest.lan" ];

  networking.hosts."192.168.188.100" = [ "kona-micro.lan" ];
  networking.hosts."192.168.188.101" = [ "wirnet.lan" ];
  networking.hosts."192.168.188.102" = [ "conduit.lan" ];
}
