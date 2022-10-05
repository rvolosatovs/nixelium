{...}: {pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_enarx;

  hardware.cpu.amd.sev.enable = true;
  hardware.cpu.amd.sev.mode = "0660";

  hardware.cpu.amd.updateMicrocode = true;

  hardware.firmware = [pkgs.linux-firmware];

  services.enarx.backend = "sev";
}
