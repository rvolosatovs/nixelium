{ config, lib, confdir, addr, hostname ? "my", ... }:

with lib;

assert (confdir != null);
assert (addr != null);
assert (hostname != null);

{
  config.services.openvpn.servers = listToAttrs nameValuePair hostname { config = 
  ''
  client
  dev tun
  proto udp
  sndbuf 0
  rcvbuf 0
  remote ${addr}
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
  cert ${confdir}/${hostname}.crt
  key ${confdir}/${hostname}.key
  '';
      };
    }
