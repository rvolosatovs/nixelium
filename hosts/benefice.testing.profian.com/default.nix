{modulesPath, ...}: {
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
  ];

  networking.domain = "testing.profian.com";
  networking.hostName = "benefice";
}
