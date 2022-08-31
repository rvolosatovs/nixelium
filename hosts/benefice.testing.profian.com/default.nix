{modulesPath, ...}: {
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
  ];

  # NOTE: /dev/kvm is not present on the system
  services.enarx.backend = "nil";
}
