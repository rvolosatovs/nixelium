{ config, pkgs, lib, ... }:

let
  unstable = import <nixpkgs-unstable> {};

  keys = import ../../var/keys.nix;
  secrets = import ../../var/secrets.nix;
  vars = import ../../var/variables.nix { inherit pkgs; } // {
    luksName = "luksroot";
    luksDevice = "/dev/sda3";
    isSSD = false;
    hostname = "oxygen";
    netDeviceMAC = "90:1b:0e:ff:70:ba";
  };

  machine = secrets.machines.oxygen;
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
    ../../lib/common.nix
    ../../lib/luks.nix
    #../../lib/mopidy.nix
  ];

  boot.kernelParams = [ "ip=${machine.addr}::${machine.gateway}:${machine.netmask}::${vars.netDeviceName}:none" ];
  boot.initrd.network.enable = true;
  boot.initrd.network.postCommands = ''
    echo "cryptsetup-askpass; exit" > /root/.profile
  '';
  boot.initrd.network.ssh.authorizedKeys = [ keys.publicKey ];
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.hostRSAKey = ./id_dropbear;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  networking.defaultGateway = machine.gateway;
  networking.firewall.allowedTCPPorts = [ 9091 ];
  networking.firewall.enable = true;
  networking.interfaces."${vars.netDeviceName}" = {
    ipAddress    = machine.addr;
    prefixLength = if machine.netmask == "255.255.255.0" then 24 else "TODO";
  };
  networking.nameservers = machine.dns;
  networking.useDHCP = false;
  networking.usePredictableInterfaceNames = false;

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${vars.netDeviceMAC}", NAME="${vars.netDeviceName}"
  '';
}
