{self, ...}: {
  withSecret = config: pkgs: user: secret: let
    expose = self.lib.scripts.exposeKey pkgs user config.sops.secrets.${secret}.path;
    hide = self.lib.scripts.hideKey pkgs config.users.users.root.name config.sops.secrets.${secret}.path;
  in {
    serviceConfig.ExecStartPre = "+${expose}";
    serviceConfig.ExecStop = "+${hide}";
    serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];
  };
}
