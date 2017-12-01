{ config, pkgs, lib, ... }:

let
  keys = import ./keys.nix;
  secrets = import ./secrets.nix;
  vars = import ./variables.nix;

  unstable = import <nixpkgs-unstable> {};
  mypkgs = import <mypkgs> {};
}
in
  {
    imports = [
      ./hardware-configuration.nix
      ../../lib/thinkpad.nix
      ../../lib/programs-base.nix
      ../../lib/programs-graphical.nix
      ../../lib/mopidy.nix
      ../../lib/encrypted-root.nix
    ];
  }

