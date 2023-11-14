{
  self,
  nixpkgs-unstable,
  ...
}: final: prev: let
  mkDiskImage = import "${nixpkgs-unstable}/nixos/lib/make-disk-image.nix";
in
  with prev.lib;
    {
      install-iso-aarch64-linux = self.nixosConfigurations.install-aarch64.config.system.build.isoImage;
      install-iso-x86_64-linux = self.nixosConfigurations.install-x86_64.config.system.build.isoImage;
    }
    // optionalAttrs prev.stdenv.buildPlatform.isLinux {
      iridium-phosphorus-cloud-image = mkDiskImage {
        config = self.nixosConfigurations.iridium-phosphorus.config;
        copyChannel = false;
        format = "qcow2-compressed";
        lib = final.lib;
        name = "iridium-phosphorus-cloud-image";
        pkgs = final;
      };
    }
