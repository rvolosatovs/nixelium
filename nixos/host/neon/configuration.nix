{ config, pkgs, ... }:

rec {
  # This will be passed to all imports
  _module.args = {
    mypkgs = import <mypkgs> {};
    unstable = import <nixpkgs-unstable> {};

    keys = import ../../var/keys.nix;
    secrets = import ../../var/secrets.nix;
    vars = import ../../var/variables.nix { inherit pkgs; } // {
      luksName = "luksroot";
      luksDevice = "/dev/sda2";
    };
  };

  imports = [
    ./hardware-configuration.nix
    ../../lib/hardware/lenovo-x260.nix
    ../../lib/common.nix
    ../../lib/luks.nix
    ../../lib/mopidy.nix
    ../../lib/ovpn.nix
    ../../lib/graphical.nix
  ];

  networking.firewall.allowedTCPPorts = [ 3001 42424 ];

  services.xserver.xrandrHeads = [ "DP1" "eDP1" ];
  services.xserver.resolutions = [ { x = 3840; y = 2160; } { x = 1920; y = 1080; } ];
  #services.xserver.xrandrHeads = [ "HDMI2" "eDP1" ];
  #services.xserver.resolutions = [ { x = 1920; y = 1080; } { x = 1920; y = 1080; } ];

  #virtualisation.rkt.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.headless = true;
  #virtualisation.virtualbox.guest.enable = true;
}
