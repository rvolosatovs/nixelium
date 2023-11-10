{self, ...}: let
  tooling = pkgs: _: rec {
    bootstrap-ca = let
      key = ''"ca/''${1}/ca.key"'';
      crt = ''"ca/''${1}/ca.crt"'';
      conf = pkgs.writeText "ca.conf" ''
        [req]
        distinguished_name = req_distinguished_name
        prompt = no
        x509_extensions = v3_ca

        [req_distinguished_name]
        C  = CH
        ST = Valais
        L  = Crans-Montana
        CN = rvolosatovs.dev

        [v3_ca]
        basicConstraints = critical,CA:TRUE
        keyUsage = cRLSign, keyCertSign
        nsComment = "rvolosatovs.dev CA certificate"
        subjectKeyIdentifier = hash
      '';
    in
      pkgs.writeShellScriptBin "bootstrap-ca" ''
        set -xe

        umask 0077

        ${pkgs.openssl}/bin/openssl ecparam -genkey -name prime256v1 | ${pkgs.openssl}/bin/openssl pkcs8 -topk8 -nocrypt -out ${key}
        ${pkgs.openssl}/bin/openssl req -new -x509 -days 365 -config ${conf} -key ${key} -out ${crt}
        ${pkgs.sops}/bin/sops -e -i ${key}
      '';

    bootstrap = pkgs.writeShellScriptBin "bootstrap" ''
      set -e

      for host in ca/*; do
          ${bootstrap-ca}/bin/bootstrap-ca "''${host#'ca/'}"
      done
    '';

    host-key = pkgs.writeShellScriptBin "host-key" ''
      set -e

      ${pkgs.openssh}/bin/ssh-keyscan "''${1}" 2> /dev/null | ${pkgs.gnugrep}/bin/grep 'ssh-ed25519' | ${pkgs.ssh-to-age}/bin/ssh-to-age
    '';

    ssh-for-each = pkgs.writeShellScriptBin "ssh-for-each" ''
      for host in ${self}/hosts/*; do
          ${pkgs.openssh}/bin/ssh "''${host#'${self}/hosts/'}" ''${@}
      done
    '';
  };
in
  final: prev: tooling final prev
