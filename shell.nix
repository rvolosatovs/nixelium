with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "env";
  buildInputs = let
    keybaseRepos = [ "vendor/pass" "vendor/pass-ttn-shared" "vendor/pass-otp" ];

    writeAllReposScriptBin = name: action: writeShellScriptBin name (''
      set -x
      ${action}
      ${git}/bin/git submodule foreach "${action} || :"
    '' + lib.concatMapStringsSep "\n" (x: "(cd ${x} && ${action})") keybaseRepos);

    fetchAll = writeAllReposScriptBin "fetch-all" "${git}/bin/git fetch --prune --all";
    pullAll = writeAllReposScriptBin "pull-all" "${git}/bin/git pull";
    pushAll = writeAllReposScriptBin "push-all" "${git}/bin/git push -f --prune origin :";

    pullAndDeploy = writeShellScriptBin "pull-and-deploy" ''
      set -ex
      ${pullAll}/bin/pull-all
      ${nixops}/bin/nixops deploy "''${@}"
    '';

    upgradeMac = writeShellScriptBin "upgrade-mac" ''
      set -ex
      ${git}/bin/git pull
      ${nix}/bin/nix-channel --update
      darwin-rebuild switch "''${@}"
      brew update --global
    '';
  in [
    fetchAll
    pullAll
    pullAndDeploy
    pushAll
  ] ++ [
    git
    neovim
    nixops
  ]
  ++ lib.optional stdenv.isLinux keybase
  ++ lib.optional stdenv.isDarwin upgradeMac
  ;
}
