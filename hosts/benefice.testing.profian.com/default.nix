{modulesPath, ...}: {
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"

    ../../inventory/groups/meta/common.nix
  ];

  # NOTE: /dev/kvm is not present on the system
  services.enarx.backend = "nil";
}
