{self, ...}: _: _: {
  install-iso-aarch64-linux = self.nixosConfigurations.install-aarch64.config.system.build.isoImage;
  install-iso-x86_64-linux = self.nixosConfigurations.install-x86_64.config.system.build.isoImage;
}
