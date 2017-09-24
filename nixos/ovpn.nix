{ lib, confdir, addr, hostname ? "my", ... }:

with lib;

{
  servers."${hostname}".config = 
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
}
    #}

    #{ config, lib, secrets, ... }:
    #
    #with lib;
    #
    #{
      #  config.services.openvpn.servers = listToAttrs nameValuePair hostname { config = 
      #  ''
        #  client
        #  dev tun
        #  proto udp
        #  sndbuf 0
        #  rcvbuf 0
        #  remote ${secrets.vpn.addr}
        #  resolv-retry infinite
        #  nobind
        #  persist-key
        #  persist-tun
        #  remote-cert-tls server
        #  auth SHA512
        #  cipher AES-256-CBC
        #  comp-lzo
        #  setenv opt block-outside-dns
        #  key-direction 1
        #  verb 3
        #  ca /home/rvolosatovs/ca.crt
        #  tls-auth /home/rvolosatovs/tls.key
        #  cert /home/rvolosatovs/${secrets.vpn.hostname}.crt
        #  key /home/rvolosatovs/${secrets.vpn.hostname}.key
        #  '';
          #      };
          #    }
