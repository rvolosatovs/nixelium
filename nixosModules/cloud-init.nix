{nixlib, ...}: {modulesPath, ...}: {
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  fileSystems."/".autoResize = true;
  fileSystems."/".fsType = "ext4";
  fileSystems."/".label = "root";

  services.cloud-init.btrfs.enable = true;
  services.cloud-init.enable = true;
  services.cloud-init.ext4.enable = true;
  services.cloud-init.network.enable = true;

  services.qemuGuest.enable = true;
}
