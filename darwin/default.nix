{ pkgs, ... }:

{
  imports = [
    (import ../vendor/home-manager { inherit pkgs; }).nix-darwin
    ./../modules
    ./common.nix
  ];
}
