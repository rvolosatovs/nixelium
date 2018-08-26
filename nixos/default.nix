{ pkgs, ... }:

{
  imports = [
    (import ../vendor/home-manager { inherit pkgs; }).nixos
    ./../modules
    ./common.nix
  ];
}
