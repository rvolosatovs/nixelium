{...}: {...}: {
  boot.kernelModules = [
    "kvm-amd"
  ];

  hardware.cpu.amd.sev.enable = true;
  hardware.cpu.amd.sev.mode = "0660";

  hardware.cpu.amd.updateMicrocode = true;

  services.enarx.backend = "sev";
}
