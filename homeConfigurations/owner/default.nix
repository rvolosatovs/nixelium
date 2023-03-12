{
  self,
  home-manager,
  ...
}:
home-manager.lib.homeManagerConfiguration {
  modules = [
    self.homeModules.default
  ];
}
