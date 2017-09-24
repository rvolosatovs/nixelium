{ name, addr, ... }:
{
services = {
  openvpn = {

  };
};
}
{
  config = ''
     remote ${name} 1194
     dev tun0
     ifconfig 10.8.0.2 10.8.0.1
     secret /root/static.key
     mtu-test
     comp-lzo
  '';
  up = ''
     ip route add table 50 default via 10.8.0.1 dev tun0
     ip route add table 50 throw 10.8.0.1
     ip route add table 50 throw 192.168.0.0/16
     ip route add table 50 throw ${addr}
     ip rule add from all pref 50 table 50
  '';
  down = ''
     ip rule del pref 50
     ip route del table 50 default
     ip route del table 50 throw 10.8.0.1
     ip route del table 50 throw 192.168.0.0/16
     ip route del table 50 throw ${addr}
  '';
  autoStart = false;
}
