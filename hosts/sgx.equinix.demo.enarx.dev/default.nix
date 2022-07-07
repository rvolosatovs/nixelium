{lib, ...}: {
  imports = [
    ../../modules/providers/equinix
  ];

  boot.initrd.availableKernelModules = [
    "megaraid_sas"
  ];
  boot.kernelModules = [
    "kvm-intel"
  ];

  fileSystems."/".device = "/dev/disk/by-id/ata-MTFDDAV240TDU_220133CB3E88-part3";
  fileSystems."/boot/efi".device = "/dev/disk/by-id/ata-MTFDDAV240TDU_220133CB3E88-part1";

  hardware.cpu.intel.sgx.aesmd.enable = true;
  hardware.cpu.intel.sgx.provision.enable = true;
  hardware.cpu.intel.sgx.provision.service.apiKey = "/var/lib/pccs/api-key";
  hardware.cpu.intel.sgx.provision.service.enable = true;

  networking.hostId = "395c78d1";
  networking.interfaces.eno12399.useDHCP = true;
  networking.interfaces.eno12409.useDHCP = true;
  networking.interfaces.eno12419.useDHCP = true;
  networking.interfaces.eno12429.useDHCP = true;

  nix.maxJobs = lib.mkDefault 128;

  swapDevices = [
    {device = "/dev/disk/by-id/ata-MTFDDAV240TDU_220133CB3E88-part2";}
  ];

  systemd.network.networks."30-eno12399".matchConfig.Name = "eno12399";
  systemd.network.networks."30-eno12399".matchConfig.PermanentMACAddress = "40:a6:b7:6b:48:e8";
  systemd.network.networks."30-eno12399".networkConfig.Bond = "bond0";

  systemd.network.networks."30-eno12419".matchConfig.Name = "eno12419";
  systemd.network.networks."30-eno12419".matchConfig.PermanentMACAddress = "40:a6:b7:6b:48:ea";
  systemd.network.networks."30-eno12419".networkConfig.Bond = "bond0";

  systemd.network.networks."40-bond0".addresses = [
    {addressConfig.Address = "147.28.146.139/31";}
    {addressConfig.Address = "2604:1380:45f1:4800::3/127";}
    {addressConfig.Address = "10.68.40.3/31";}
  ];
  systemd.network.networks."40-bond0".linkConfig.MACAddress = "40:a6:b7:6b:48:e8";
  systemd.network.networks."40-bond0".linkConfig.RequiredForOnline = "carrier";
  systemd.network.networks."40-bond0".matchConfig.Name = "bond0";
  systemd.network.networks."40-bond0".networkConfig.LinkLocalAddressing = "no";
  systemd.network.networks."40-bond0".routes = [
    {routeConfig.Gateway = "147.28.146.138";}
    {routeConfig.Gateway = "2604:1380:45f1:4800::2";}
    {routeConfig.Gateway = "10.68.40.2";}
  ];
}
