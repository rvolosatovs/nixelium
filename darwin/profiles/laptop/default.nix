{ config, pkgs, ... }:
{
  imports = [
    ./../..
    ./../../graphical.nix
  ];

  home-manager.users.${config.resources.username} = {...}: {
    imports = [
      ../../../home/profiles/laptop
    ];
  };
}
