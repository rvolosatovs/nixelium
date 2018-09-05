{ config, ... }:

let
  confdir = "/home/${config.resources.username}/.config/vpn";
in
{
  services.openvpn.servers.${config.secrets.servers.vpn.hostname}.config = 
  ''
    client
    dev tun
    proto udp
    sndbuf 0
    rcvbuf 0
    remote ${config.secrets.servers.vpn.addr}
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
    cert ${confdir}/${config.secrets.servers.vpn.hostname}.crt
    key ${confdir}/${config.secrets.servers.vpn.hostname}.key
  '';
}
