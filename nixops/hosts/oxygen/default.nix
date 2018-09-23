{ config, ... }:
{
  imports = [
    ./../../../nixos/hosts/oxygen
    ./../../../vendor/secrets/nixops/hosts/oxygen
    ./../../meet.nix
    ./../../profiles/server
  ];
}
