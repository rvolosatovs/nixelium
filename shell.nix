with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "env";
  buildInputs = let
    nixosVersion = "19.03";

    keybaseRepos = [ "vendor/pass" "vendor/pass-ttn-shared" "vendor/pass-otp" "vendor/secrets" ];

    cloneIfEmpty = path: url: ''
      if [ -d "${path}" ]; then
        echo "${path} already exists, skip cloning"
      else
        ${git}/bin/git clone --branch master "${url}" "${path}"
      fi
    '';

    upsertRemote = name: url: ''
      if [ $(${git}/bin/git remote | ${ripgrep}/bin/rg "${name}") ]; then
        echo "remote ${name} already exists, setting URL to ${url}"
        ${git}/bin/git remote set-url "${name}" "${url}"
      else
        ${git}/bin/git remote add "${name}" "${url}"
      fi
    '';

    addWorkTreeIfEmpty = path: commitish: ''
      if [ -d "${path}" ]; then
        echo "${path} already exists, skip adding worktree"
      else
        ${git}/bin/git worktree add "${path}" "${commitish}"
      fi
    '';

    cloneGitHubSource = repo: preFetch: postFetch: ''
      ${cloneIfEmpty "../${repo}" "https://github.com/rvolosatovs/${repo}.git"}

      pushd "../${repo}"

      ${git}/bin/git remote set-url origin --push git@github.com:rvolosatovs/${repo}.git

      ${preFetch}

      ${git}/bin/git fetch --all

      ${postFetch}

      popd
    '';

    cloneGitHubFork = owner: repo: preFetch: postFetch: ''
      ${cloneIfEmpty "../../${owner}/${repo}" "https://github.com/rvolosatovs/${repo}.git"}

      pushd "../../${owner}/${repo}"

      ${git}/bin/git remote set-url origin --push git@github.com:rvolosatovs/${repo}.git
      ${upsertRemote "upstream" "https://github.com/${owner}/${repo}.git"}

      ${preFetch}

      ${git}/bin/git fetch --all

      ${postFetch}

      popd
    '';

    vendorGitHubFork = owner: repo: ''
      ${cloneGitHubFork owner repo "" ''
        ${git}/bin/git checkout origin/master
        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/${repo}" "master"}
        pushd "../../rvolosatovs/infrastructure/vendor/${repo}"
        ${git}/bin/git branch --set-upstream-to=upstream/master
        popd
      ''}
    '';

    vendorGitHubSource = repo: ''
      ${cloneGitHubSource repo "" ''
        ${git}/bin/git checkout origin/master
        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/${repo}" "master"}
        pushd "../../rvolosatovs/infrastructure/vendor/${repo}"
        ${git}/bin/git branch --set-upstream-to=origin/master
        popd
      ''}
    '';

    vendorKeybasePrivateSource = repo: ''
      ${cloneIfEmpty "vendor/${repo}" "keybase://private/rvolosatovs/${repo}" }
    '';

    bootstrap = writeShellScriptBin "bootstrap" ''
      set -e

      ${cloneGitHubFork "NixOS" "nixpkgs" ''
        ${upsertRemote "channels" "https://github.com/NixOS/nixpkgs-channels.git"}
      '' ''
        ${git}/bin/git checkout master

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/nixos" "nixos"}
        pushd "../../rvolosatovs/infrastructure/vendor/nixpkgs/nixos"
        ${git}/bin/git branch --set-upstream-to=channels/nixos-${nixosVersion}
        popd

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/nixos-unstable" "nixos-unstable"}
        pushd "../../rvolosatovs/infrastructure/vendor/nixpkgs/nixos-unstable"
        ${git}/bin/git branch --set-upstream-to=channels/nixos-unstable
        popd

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin" "darwin"}
        pushd "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin"
        ${git}/bin/git branch --set-upstream-to=channels/nixpkgs-${nixosVersion}-darwin
        popd

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin-unstable" "darwin-unstable"}
        pushd "../../rvolosatovs/infrastructure/vendor/nixpkgs/darwin-unstable"
        ${git}/bin/git branch --set-upstream-to=channels/nixpkgs-unstable
        popd
      ''}

      ${cloneGitHubFork "rycee" "home-manager" "" ''
        ${git}/bin/git checkout master

        ${addWorkTreeIfEmpty "../../rvolosatovs/infrastructure/vendor/home-manager" "stable"}
        pushd ../../rvolosatovs/infrastructure/vendor/home-manager
        ${git}/bin/git branch --set-upstream-to="upstream/release-${nixosVersion}"
        popd
      ''}

      ${vendorGitHubFork "chriskempson" "base16-shell"}
      ${vendorGitHubFork "jitsi" "docker-jitsi-meet"}
      ${vendorGitHubFork "keyboardio" "Model01-Firmware"}
      ${vendorGitHubFork "LnL7" "nix-darwin"}
      ${vendorGitHubFork "nix-community" "nur"}
      ${vendorGitHubFork "NixOS" "nixos-hardware"}
      ${vendorGitHubFork "qmk" "qmk_firmware"}
      ${vendorGitHubFork "StevenBlack" "hosts"}

      ${vendorGitHubSource "copier"}
      ${vendorGitHubSource "dumpster"}
      ${vendorGitHubSource "gorandr"}

      ${vendorKeybasePrivateSource "pass"}
      ${vendorKeybasePrivateSource "pass-otp"}
      ${vendorKeybasePrivateSource "pass-ttn-shared"}
      ${vendorKeybasePrivateSource "secrets"}
    '';

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
      ${git}/bin/git submodule update
      ${nix}/bin/nix-channel --update
      darwin-rebuild switch "''${@}"
      brew bundle install --global
    '';
  in [
    bootstrap
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
