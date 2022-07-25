{self, ...}: final: prev: let
  bootstrap-ca = let
    key = ''"ca/''${1}/ca.key"'';
    crt = ''"ca/''${1}/ca.crt"'';
    conf = final.writeText "ca.conf" ''
      [req]
      distinguished_name = req_distinguished_name
      prompt = no
      x509_extensions = v3_ca

      [req_distinguished_name]
      C   = US
      ST  = North Carolina
      L   = Raleigh
      CN  = Proof of Concept

      [v3_ca]
      basicConstraints = critical,CA:TRUE
      keyUsage = cRLSign, keyCertSign
      nsComment = "Profian CA certificate"
      subjectKeyIdentifier = hash
    '';

    openssl = "${final.openssl}/bin/openssl";
    sops = "${final.sops}/bin/sops";
  in
    final.writeShellScriptBin "bootstrap-ca" ''
      set -xe

      umask 0077

      ${openssl} ecparam -genkey -name prime256v1 | ${openssl} pkcs8 -topk8 -nocrypt -out ${key}
      ${openssl} req -new -x509 -days 365 -config ${conf} -key ${key} -out ${crt}
      ${sops} -e -i ${key}
    '';

  bootstrap-steward = let
    ca.key = ''"ca/''${1}/ca.key"'';
    ca.crt = ''"ca/''${1}/ca.crt"'';

    steward.key = ''"hosts/attest.''${1}/steward.key"'';
    steward.csr = ''"hosts/attest.''${1}/steward.csr"'';
    steward.crt = ''"hosts/attest.''${1}/steward.crt"'';

    conf = final.writeText "steward.conf" ''
      [req]
      distinguished_name = req_distinguished_name
      prompt = no
      x509_extensions = v3_ca

      [req_distinguished_name]
      C   = US
      ST  = North Carolina
      L   = Raleigh
      CN  = Proof of Concept

      [v3_ca]
      basicConstraints = critical,CA:TRUE
      keyUsage = cRLSign, keyCertSign
      nsComment = "Profian attestation service CA certificate"
      subjectKeyIdentifier = hash
    '';

    openssl = "${final.openssl}/bin/openssl";
    sops = "${final.sops}/bin/sops";

    sign-cert = "${final.writeShellScriptBin "sign-cert" ''
      set -xe

      ${openssl} x509 -req -days 365 -CAcreateserial -CA ${ca.crt} -CAkey "''${2}" -in ${steward.csr} -out ${steward.crt} -extfile ${conf} -extensions v3_ca
    ''}/bin/sign-cert";
  in
    final.writeShellScriptBin "bootstrap-steward" ''
      set -xe

      umask 0077

      ${openssl} ecparam -genkey -name prime256v1 | ${openssl} pkcs8 -topk8 -nocrypt -out ${steward.key}
      ${openssl} req -new -config ${conf} -key ${steward.key} -out ${steward.csr}
      ${sops} -e -i ${steward.key}

      ${sops} exec-file ${ca.key} "${sign-cert} \"''${1}\" {}"
    '';

  bootstrap = let
    bootstrap-ca = "${final.bootstrap-ca}/bin/bootstrap-ca";
    bootstrap-steward = "${final.bootstrap-steward}/bin/bootstrap-steward";
  in
    final.writeShellScriptBin "bootstrap" ''
      set -e

      for host in ca/*; do
          ${bootstrap-ca} "''${host#'ca/'}"
      done

      for host in hosts/attest.*; do
          ${bootstrap-steward} "''${host#'hosts/attest.'}"
      done
    '';
in {
  inherit
    bootstrap
    bootstrap-ca
    bootstrap-steward
    ;
}
