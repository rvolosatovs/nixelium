{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};

  graphical = true;

  keys = import ../../var/keys.nix;
  secrets = import ../../var/secrets.nix;
  vars = import ../../var/variables.nix { inherit pkgs graphical; };
in

rec {
  _module.args = {
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

  nix.nixPath = [
    "nixpkgs=/nix/nixpkgs"
    "nixpkgs-unstable=/nix/var/nix/profiles/per-user/root/channels/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
  nixpkgs.config.allowUnfree = true;
  networking.firewall.allowedTCPPortRanges = [ { from = 2300; to = 2400; }];
  networking.firewall.allowedTCPPorts = [ 3001 42424 47624 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 2300; to = 2400; }];
  networking.firewall.allowedUDPPorts = [ 47624 ];
  networking.firewall.trustedInterfaces = [ "vboxnet0" ];
  networking.hostName = "neon";
  networking.networkmanager.enable = true;

  programs.adb.enable = true;
  #programs.java.enable = true;
  programs.wireshark.enable = true;

  #security.pam.services.i3lock.fprintAuth = true;

  security.polkit.extraConfig = ''
    /* https://wiki.archlinux.org/index.php/Fprint#Restrict_enrolling */
    polkit.addRule(function (action, subject) {
      if (action.id == "net.reactivated.fprint.device.enroll") {
        return subject.user == "root" ? polkit.Result.YES : polkit.result.NO
      }
    })
  '';

  #services.dnscrypt-proxy.enable = true;
  #services.kbfs.enable = true;
  #services.keybase.enable = true;
  services.printing.enable = true;
  services.samba.enable = true;
  #services.syncthing.enable = true;
  #services.syncthing.openDefaultPorts = true;
  #services.syncthing.user = vars.username;
  #services.xserver.resolutions = [ { x = 1920; y = 1080; } { x = 3840; y = 2160; } ];
  #services.xserver.xrandrHeads = [ "eDP1" "DP1" ];
  services.udev.extraRules = ''
    # General
    KERNEL=="ttyACM*", OWNER="${vars.username}"
    KERNEL=="ttyUSB*", OWNER="${vars.username}"

    # OLKB kerboards
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="feed", OWNER="${vars.username}"

    # Keyboardio
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", OWNER="${vars.username}"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", OWNER="${vars.username}"

    # Atmel ATMega32U4
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", OWNER="${vars.username}"

    # Atmel USBKEY AT90USB1287
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffb", OWNER="${vars.username}"

    # Atmel ATMega32U2
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff0", OWNER="${vars.username}"

    # SparkFun Pro Micro
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9204", OWNER="${vars.username}"

    # Teensy
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", OWNER="${vars.username}"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"

    #
    # Debuggers
    #

    # Black Magic Probe
    SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic GDB Server"
    SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic UART Port"

    # opendous and estick
    ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="204f", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Original FT232/FT245 VID:PID
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Original FT2232 VID:PID
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Original FT4232 VID:PID
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Original FT232H VID:PID
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # DISTORTEC JTAG-lock-pick Tiny 2
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="8220", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # TUMPA, TUMPA Lite
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="8a98", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="8a99", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # XDS100v2
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="a6d0", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Xverve Signalyzer Tool (DT-USB-ST), Signalyzer LITE (DT-USB-SLITE)
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="bca0", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="bca1", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # TI/Luminary Stellaris Evaluation Board FTDI (several)
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="bcd9", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # TI/Luminary Stellaris In-Circuit Debug Interface FTDI (ICDI) Board
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="bcda", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # egnite Turtelizer 2
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="bdc8", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Section5 ICEbear
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="c140", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="c141", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Amontec JTAGkey and JTAGkey-tiny
    ATTRS{idVendor}=="0403", ATTRS{idProduct}=="cff8", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # TI ICDI
    ATTRS{idVendor}=="0451", ATTRS{idProduct}=="c32a", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # STLink v1
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3744", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # STLink v2
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # STLink v2-1
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Hilscher NXHX Boards
    ATTRS{idVendor}=="0640", ATTRS{idProduct}=="0028", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Hitex STR9-comStick
    ATTRS{idVendor}=="0640", ATTRS{idProduct}=="002c", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Hitex STM32-PerformanceStick
    ATTRS{idVendor}=="0640", ATTRS{idProduct}=="002d", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Altera USB Blaster
    ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Amontec JTAGkey-HiSpeed
    ATTRS{idVendor}=="0fbb", ATTRS{idProduct}=="1000", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # SEGGER J-Link
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0101", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0102", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0103", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0104", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0107", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0108", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1010", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1011", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1012", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1013", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1014", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1016", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1017", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1018", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Raisonance RLink
    ATTRS{idVendor}=="138e", ATTRS{idProduct}=="9000", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Debug Board for Neo1973
    ATTRS{idVendor}=="1457", ATTRS{idProduct}=="5118", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Olimex ARM-USB-OCD
    ATTRS{idVendor}=="15ba", ATTRS{idProduct}=="0003", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Olimex ARM-USB-OCD-TINY
    ATTRS{idVendor}=="15ba", ATTRS{idProduct}=="0004", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Olimex ARM-JTAG-EW
    ATTRS{idVendor}=="15ba", ATTRS{idProduct}=="001e", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Olimex ARM-USB-OCD-TINY-H
    ATTRS{idVendor}=="15ba", ATTRS{idProduct}=="002a", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Olimex ARM-USB-OCD-H
    ATTRS{idVendor}=="15ba", ATTRS{idProduct}=="002b", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # USBprog with OpenOCD firmware
    ATTRS{idVendor}=="1781", ATTRS{idProduct}=="0c63", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # TI/Luminary Stellaris In-Circuit Debug Interface (ICDI) Board
    ATTRS{idVendor}=="1cbe", ATTRS{idProduct}=="00fd", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Marvell Sheevaplug
    ATTRS{idVendor}=="9e88", ATTRS{idProduct}=="9e8f", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # Keil Software, Inc. ULink
    ATTRS{idVendor}=="c251", ATTRS{idProduct}=="2710", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # CMSIS-DAP compatible adapters
    ATTRS{product}=="*CMSIS-DAP*", MODE="660", GROUP="plugdev", TAG+="uaccess"
  '';

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
