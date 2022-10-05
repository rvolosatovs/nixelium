{...}: {
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.profian.provider;
in {
  options.profian.provider = mkOption {
    type = with types; nullOr (enum ["aws" "equinix"]);
    description = "Hosting provider.";
    default = null;
  };
  options.ec2.instance = mkOption {
    type = types.enum ["t2.micro" "m6a.metal"];
    description = "EC2 instance type.";
  };
  config = mkMerge [
    (mkIf (cfg == "aws" && config.ec2.instance == "t2.micro") {
      # NOTE: /dev/kvm is not present on t2.micro instances
      services.enarx.backend = "nil";
    })
    (mkIf (cfg == "equinix") {
      boot.extraModprobeConfig = "options bonding max_bonds=0";
      boot.initrd.availableKernelModules = [
        "ahci"
        "sd_mod"
        "xhci_pci"
      ];
      boot.kernelModules = [
        "dm_multipath"
        "dm_round_robin"
        "ipmi_watchdog"
      ];
      boot.kernelParams = [
        "console=ttyS1,115200n8"
      ];
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";
      boot.loader.systemd-boot.enable = true;

      fileSystems."/".fsType = "ext4";
      fileSystems."/boot/efi".fsType = "vfat";

      hardware.enableAllFirmware = true;

      networking.useDHCP = false;
      networking.useNetworkd = true;

      nixpkgs.config.allowUnfree = true;

      systemd.network.netdevs."10-bond0".bondConfig.DownDelaySec = 0.2;
      systemd.network.netdevs."10-bond0".bondConfig.LACPTransmitRate = "fast";
      systemd.network.netdevs."10-bond0".bondConfig.MIIMonitorSec = 0.1;
      systemd.network.netdevs."10-bond0".bondConfig.Mode = "802.3ad";
      systemd.network.netdevs."10-bond0".bondConfig.TransmitHashPolicy = "layer3+4";
      systemd.network.netdevs."10-bond0".bondConfig.UpDelaySec = 0.2;
      systemd.network.netdevs."10-bond0".netdevConfig.Kind = "bond";
      systemd.network.netdevs."10-bond0".netdevConfig.Name = "bond0";

      systemd.network.networks."40-bond0".dns = [
        "147.75.207.207"
        "147.75.207.208"
      ];

      systemd.network.wait-online.anyInterface = true;
    })
  ];
}
