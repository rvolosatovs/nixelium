{ config, pkgs, lib, ... }:
{
  imports = [
    ./../../../resources/hosts/krypton
    ./../../hardware/macbook-pro/15-2
    ./../../profiles/laptop
  ];

  config = {
    environment.darwinConfig = toString ./.;

    home-manager.users.${config.resources.username} = {...}: {
      imports = [
        ./../../../home/hosts/krypton
      ];
    };

    networking.hostName = "krypton";

    nix.nixPath = lib.mkBefore [
      "darwin-config=${config.environment.darwinConfig}"
    ];
  };
}
