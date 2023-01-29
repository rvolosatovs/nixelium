inputs @ {
  self,
  nixlib,
  ...
}: let
  tooling = nixlib.lib.composeManyExtensions [
    (final: prev: let
      host-key = let
        grep = "${final.gnugrep}/bin/grep";
        ssh-keyscan = "${final.openssh}/bin/ssh-keyscan";
        ssh-to-age = "${final.ssh-to-age}/bin/ssh-to-age";
      in
        final.writeShellScriptBin "host-key" ''
          set -e

          ${ssh-keyscan} "''${1}" 2> /dev/null | ${grep} 'ssh-ed25519' | ${ssh-to-age}
        '';

      ssh-for-each = final.writeShellScriptBin "ssh-for-each" ''
        for host in ${self}/hosts/*; do
            ${final.openssh}/bin/ssh "''${host#'${self}/hosts/'}" ''${@}
        done
      '';
    in {
      inherit
        host-key
        ssh-for-each
        ;
    })
    (import ./bootstrap.nix inputs)
  ];
in {
  inherit tooling;
  default = tooling;
}
