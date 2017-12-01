{ secrets, vars, ... }:

let
  confdir = "/home/${vars.username}/.config/vpn";
in
{
  services.openvpn.servers."${secrets.servers.vpn.hostname}".config = 
  ''
    client
    dev tun
    proto udp
    sndbuf 0
    rcvbuf 0
    remote ${secrets.servers.vpn.addr}
    resolv-retry infinite
    nobind
    persist-key
    persist-tun
    remote-cert-tls server
    auth SHA512
    cipher AES-256-CBC
    comp-lzo
    setenv opt block-outside-dns
    key-direction 1
    verb 3
    ca ${confdir}/ca.crt
    tls-auth ${confdir}/tls.key
    cert ${confdir}/${secrets.servers.vpn.hostname}.crt
    key ${confdir}/${secrets.servers.vpn.hostname}.key
  '';
}
