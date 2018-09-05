let
  hosts = import ./../
{
  networking.wireguard.interfaces.wg0.ips = [ "10.0.0.0" ${config.meta.wireguardServerIP}]
}
