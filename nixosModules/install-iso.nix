{
  self,
  nixlib,
  ...
}: {modulesPath, ...}:
with nixlib.lib; {
  imports = [
    "${modulesPath}/installer/cd-dvd/channel.nix"
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  isoImage.squashfsCompression = mkDefault "gzip -Xcompression-level 1";
}
