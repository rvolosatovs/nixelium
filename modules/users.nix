{
  config,
  pkgs,
  ...
}: let
  keys.haraldh = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/ziasupvk3yQ6Tqb/JiQ6gPwdKzDR26S5W5w6byx3FYEztkiGLi8wsFC+mOWrirwVTma3M0TO1DnYjwXvsU7kSoQQarS8bG+CoPIifcF1a5SEeJKPifsYUIB7GSMUY4yomdRe7+AdP8nSqlHdoij6fN/+rfUs+3nTrq4TAkFyg5hqQBQp32DrM1Och5KXMvOCak75TQoxrfpKyhlCuoWVotnvxWMFgfCGUYC6Q2nKPn3y1EtFs9Y/Zi8H5VzLjrhmbJYd7yTA6HPBqDpEnaaL+vXAoqPC1Vzu+gI2jOumhg+4eN3kfbzP5Sz0ljhmYKpHBPE0+sPKMLtWZBW9gUSr";
  keys.npmccallum = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDY5lUiLQkHiSAcvIK0RNzZfGQqyt/jjmnq/vUvLLjaEzwFEHemzaOEOACQT/SC0SP/RyN/taQBkcyGGaJ9lf5Q=";
  keys.platten = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICINJWxtAQ9+03WqKkLphYQ9/k43a7YX/OUAufZoXfb+";
  keys.rvolosatovs = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX";

  adminGroups = with config.users.groups; [
    deploy.name
    ops.name
    wheel.name
  ];
in {
  security.sudo.extraRules = let
    # systemPath is the path where the system being activated is uploaded by `deploy`.
    systemPath = "/nix/store/*-activatable-nixos-system-${config.networking.hostName}-*";

    nopasswd = command: {
      inherit command;
      options = ["NOPASSWD" "SETENV"];
    };
  in [
    {
      groups = with config.users.groups; [deploy.name];
      runAs = config.users.users.root.name;
      commands = [
        (nopasswd "${systemPath}/activate-rs activate *")
        (nopasswd "${systemPath}/activate-rs wait *")
        (nopasswd "/run/current-system/sw/bin/rm /tmp/deploy-rs*")
      ];
    }
    {
      groups = with config.users.groups; [wheel.name];
      runAs = config.users.users.root.name;
      commands = [
        (nopasswd "ALL")
      ];
    }
    {
      groups = with config.users.groups; [ops.name];
      runAs = config.users.users.root.name;
      commands = [
        (nopasswd "/run/current-system/sw/bin/systemctl reboot")
        (nopasswd "/run/current-system/sw/bin/systemctl restart *")
        (nopasswd "/run/current-system/sw/bin/systemctl start *")
        (nopasswd "/run/current-system/sw/bin/systemctl stop *")
      ];
    }
  ];

  users.groups.deploy = {};
  users.groups.ops = {};

  users.users.deploy.isSystemUser = true;
  users.users.deploy.group = config.users.groups.deploy.name;
  users.users.deploy.openssh.authorizedKeys.keys = with keys; [
    haraldh
    npmccallum
    rvolosatovs
  ];
  users.users.deploy.shell = pkgs.bashInteractive;

  users.users.haraldh.isNormalUser = true;
  users.users.haraldh.extraGroups = adminGroups;
  users.users.haraldh.openssh.authorizedKeys.keys = with keys; [haraldh];
  users.users.haraldh.shell = pkgs.bashInteractive;

  users.users.npmccallum.isNormalUser = true;
  users.users.npmccallum.extraGroups = adminGroups;
  users.users.npmccallum.openssh.authorizedKeys.keys = with keys; [npmccallum];
  users.users.npmccallum.shell = pkgs.bashInteractive;

  users.users.platten.isNormalUser = true;
  users.users.platten.extraGroups = adminGroups;
  users.users.platten.openssh.authorizedKeys.keys = with keys; [platten];
  users.users.platten.shell = pkgs.bashInteractive;

  users.users.rvolosatovs.isNormalUser = true;
  users.users.rvolosatovs.extraGroups = adminGroups;
  users.users.rvolosatovs.openssh.authorizedKeys.keys = with keys; [rvolosatovs];
  users.users.rvolosatovs.shell = pkgs.zsh;
}
