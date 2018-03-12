{ config, pkgs, ... }:

let
    unstable = import <nixpkgs-unstable> {};

    keys = import ../../var/keys.nix;
    secrets = import ../../var/secrets.nix;
    vars = import ../../var/variables.nix { inherit pkgs; } // {
      browser = "${pkgs.chromium}/bin/chromium";
      mailer = "${pkgs.thunderbird}/bin/thunderbird";
    };
in


rec {
  _module.args = {
    inherit unstable;
    inherit vars;
    inherit secrets;
    inherit keys;
  };

  imports = [
    ./hardware-configuration.nix
    ../../lib/hardware/lenovo-x260.nix
    ../../lib/common.nix
    ../../lib/luks.nix
    ../../lib/mopidy.nix
    #../../lib/ovpn.nix
    ../../lib/graphical.nix
  ];

  environment.systemPackages = with pkgs; [
  ];

  networking.firewall.allowedTCPPorts = [ 3001 42424 ];
  networking.firewall.trustedInterfaces = [ "vboxnet0" ];
  networking.networkmanager.enable = true;

  programs.adb.enable = true;
  programs.java.enable = true;
  programs.wireshark.enable = true;

  #services.dnscrypt-proxy.enable = true;
  services.kbfs.enable = true;
  services.keybase.enable = true;
  services.printing.enable = true;
  services.samba.enable = true;
  services.syncthing.enable = true;
  services.syncthing.openDefaultPorts = true;
  services.syncthing.user = vars.username;
  services.xserver.resolutions = [ { x = 3840; y = 2160; } { x = 1920; y = 1080; } ];
  services.xserver.xrandrHeads = [ "DP1" "eDP1" ];

    systemd.services = {
        audio-off = {
          enable = true;
          description = "Mute audio before suspend";
          wantedBy = [ "sleep.target" ];
          serviceConfig = {
            Type = "oneshot";
            User = "${vars.username}";
            ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
            RemainAfterExit = true;
          };
        };

        #godoc = {
          #enable = true;
          #wantedBy = [ "multi-user.target" ];
          #environment = {
            #"GOPATH" = "/home/${vars.username}";
          #};
          #serviceConfig = {
            #User = "${vars.username}";
            #ExecStart = "${pkgs.gotools}/bin/godoc -http=:6060";
          #};
        #};

        #openvpn-reconnect = {
          #enable = true;
          #description = "Restart OpenVPN after suspend";

          #wantedBy= [ "sleep.target" ];

          #serviceConfig = {
            #ExecStart="${pkgs.procps}/bin/pkill --signal SIGHUP --exact openvpn";
          #};
        #};
    };

  #services.logind.extraConfig = ''
      #IdleAction=suspend
      #IdleActionSec=300
  #'';

  virtualisation.virtualbox.host.enable = true;
  #virtualisation.rkt.enable = true;
  #virtualisation.virtualbox.host.headless = true;
}
