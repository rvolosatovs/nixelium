{ config, ... }:
{
  imports = [
    ./../../../nixos/hosts/oxygen
    ./../../../vendor/secrets/nixops/hosts/oxygen
    ./../../profiles/server
  ];
}
