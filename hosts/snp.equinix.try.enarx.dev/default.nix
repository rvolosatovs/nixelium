{
  config,
  lib,
  ...
}: {
  imports = [
    ../../nixosModules/providers/equinix
  ];

  boot.initrd.availableKernelModules = [
    "mpt3sas"
    "nvme"
  ];
  boot.kernelModules = [
    "kvm-amd"
  ];
  boot.loader.grub.extraConfig = ''
    serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
    terminal_output serial console
    terminal_input serial console
  '';

  fileSystems."/".device = "/dev/disk/by-id/ata-MTFDDAV240TDU_214332305267-part3";
  fileSystems."/boot/efi".device = "/dev/disk/by-id/ata-MTFDDAV240TDU_214332305267-part1";

  hardware.cpu.amd.sev.enable = true;
  hardware.cpu.amd.sev.mode = "0660";

  hardware.cpu.amd.updateMicrocode = true;

  networking.hostId = "4a7d85ee";
  networking.interfaces.enp65s0f0.useDHCP = true;
  networking.interfaces.enp65s0f1.useDHCP = true;

  nix.maxJobs = lib.mkDefault 64;

  services.enarx.backend = "sev";

  swapDevices = [
    {device = "/dev/disk/by-id/ata-MTFDDAV240TDU_214332305267-part2";}
  ];

  systemd.network.networks."30-enp65s0f0".matchConfig.Name = "enp65s0f0";
  systemd.network.networks."30-enp65s0f0".matchConfig.PermanentMACAddress = "b4:96:91:d1:f9:20";
  systemd.network.networks."30-enp65s0f0".networkConfig.Bond = "bond0";

  systemd.network.networks."30-enp65s0f1".matchConfig.Name = "enp65s0f1";
  systemd.network.networks."30-enp65s0f1".matchConfig.PermanentMACAddress = "b4:96:91:d1:f9:21";
  systemd.network.networks."30-enp65s0f1".networkConfig.Bond = "bond0";

  systemd.network.networks."40-bond0".addresses = [
    {addressConfig.Address = "147.28.141.201/31";}
    {addressConfig.Address = "2604:1380:4642:7c00::5/127";}
    {addressConfig.Address = "10.70.216.133/31";}
  ];
  systemd.network.networks."40-bond0".linkConfig.MACAddress = "b4:96:91:d1:f9:20";
  systemd.network.networks."40-bond0".linkConfig.RequiredForOnline = "carrier";
  systemd.network.networks."40-bond0".matchConfig.Name = "bond0";
  systemd.network.networks."40-bond0".networkConfig.LinkLocalAddressing = "no";
  systemd.network.networks."40-bond0".routes = [
    {routeConfig.Gateway = "147.28.141.200";}
    {routeConfig.Gateway = "2604:1380:4642:7c00::4";}
    {routeConfig.Gateway = "10.70.216.132";}
  ];
}
