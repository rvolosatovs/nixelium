#!/usr/bin/env bash
set -e

HM_PATH=https://github.com/rycee/home-manager/archive/release-17.09.tar.gz

checkDep() {
    path=`command -v ${1}` && echo "${1} found at ${path}" || { echo "${1} not found" >&2 ; exit 1; }
}

echo "- Checking dependencies..."
checkDep nix-shell

echo "- Ensuring /nix/var/nix/{profiles,gcroots}/per-user/${USER} are present..."
mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/${USER}

echo "- Creating initial home-manager config file"
cat > ~/.config/nixpkgs/home.nix <<EOF
{
  programs.home-manager.enable = true;
  programs.home-manager.path = $HM_PATH;
}
EOF

echo "- Installing home-manager using nix-shell"
nix-shell $HM_PATH -A install
