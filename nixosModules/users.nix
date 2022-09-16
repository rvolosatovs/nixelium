{...}: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.profian;

  # systemPath is the path where the system being activated is uploaded by `deploy`.
  systemPath = "/nix/store/*-activatable-nixos-system-${config.networking.hostName}-*";

  nopasswd = command: {
    inherit command;
    options = ["NOPASSWD" "SETENV"];
  };

  keyOption = mkOption {
    type = with types; listOf singleLineStr;
    default = [];
    description = ''
      A list of verbatim OpenSSH public keys associated with the identity.
    '';
    example = [
      "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7"
      "ssh-ed25519 AAAAC3NzaCetcetera/etceteraJZMfk3QPfQ"
    ];
  };
in {
  options.profian = {
    adminGroups = mkOption {
      type = with types; listOf str;
      description = "Groups admins should be added to.";
    };
    ciKeys =
      keyOption
      // {
        description = "Authorized CI keys";
        default = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBP5eXj567djd1G54kmt1U00gsFVOex0qNldmeRAHCol"];
      };

    groups.ops.enable = mkEnableOption "ops group";

    users.deploy.enable = mkEnableOption "deploy user";
    users.deploy.ciAccess = mkEnableOption "CI deployment access";
    users.deploy.authorizedKeys = keyOption;

    users.haraldh.enable = mkEnableOption "haraldh user";
    users.haraldh.authorizedKeys =
      keyOption
      // {
        default = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/ziasupvk3yQ6Tqb/JiQ6gPwdKzDR26S5W5w6byx3FYEztkiGLi8wsFC+mOWrirwVTma3M0TO1DnYjwXvsU7kSoQQarS8bG+CoPIifcF1a5SEeJKPifsYUIB7GSMUY4yomdRe7+AdP8nSqlHdoij6fN/+rfUs+3nTrq4TAkFyg5hqQBQp32DrM1Och5KXMvOCak75TQoxrfpKyhlCuoWVotnvxWMFgfCGUYC6Q2nKPn3y1EtFs9Y/Zi8H5VzLjrhmbJYd7yTA6HPBqDpEnaaL+vXAoqPC1Vzu+gI2jOumhg+4eN3kfbzP5Sz0ljhmYKpHBPE0+sPKMLtWZBW9gUSr"];
      };

    users.jarkko.enable = mkEnableOption "jarkko user";
    users.jarkko.authorizedKeys =
      keyOption
      // {
        default = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC98lBiM9sagRbieKI6+k2TAFVbAreKupO/8Bs1EkgTIusU2VZ6y/0mBefanIArkap3G4f5kQNqnTH7077B1pfHYUTpFlGQTNN++v2+OaZFG+LXfv1mVkouw7Mo3Qdo12W6A3WGI+v0aFBwAN9kEN+Tt6jgn4/ym+iRaOTg/bG5x66csm5p598Ob6Ox0dhKA5chE736I4kb0mo09m768Fz/rR0vaQsa/vhRZfv4pmaAhBighi7s5quyQm93S85qpKs2WW8UmY6gRAwG94sER7fndxVmJOlFaCjzV/H2uVSOGQYBSZ8164JYC3AJjtGg269PcD5QqlpDr40yo9xVXkbd"];
      };

    users.npmccallum.enable = mkEnableOption "npmccallum user";
    users.npmccallum.authorizedKeys =
      keyOption
      // {
        default = ["ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDY5lUiLQkHiSAcvIK0RNzZfGQqyt/jjmnq/vUvLLjaEzwFEHemzaOEOACQT/SC0SP/RyN/taQBkcyGGaJ9lf5Q="];
      };

    users.puiterwijk.enable = mkEnableOption "puiterwijk user";
    users.puiterwijk.authorizedKeys =
      keyOption
      // {
        default = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1NBn79JAtU+9Gx/UFhG7/dEiPrHjS+ZWbuqEQAG0yG"];
      };

    users.rvolosatovs.enable = mkEnableOption "rvolosatovs user";
    users.rvolosatovs.authorizedKeys =
      keyOption
      // {
        default = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX"];
      };
  };

  config = mkMerge [
    {
      profian.adminGroups = with config.users.groups; [wheel.name];
    }

    (mkIf cfg.groups.ops.enable {
      profian.adminGroups = with config.users.groups; [ops.name];

      security.sudo.extraRules = [
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

      users.groups.ops = {};
    })

    (mkIf cfg.users.deploy.enable {
      environment.shells = with pkgs; [
        bashInteractive
      ];

      nix.settings.allowed-users = with config.users; [
        "@${groups.deploy.name}"
      ];
      nix.settings.trusted-users = with config.users; [
        "@${groups.deploy.name}"
      ];

      profian.adminGroups = with config.users.groups; [deploy.name];

      security.sudo.extraRules = [
        {
          groups = with config.users.groups; [deploy.name];
          runAs = config.users.users.root.name;
          commands = [
            (nopasswd "${systemPath}/activate-rs activate *")
            (nopasswd "${systemPath}/activate-rs wait *")
            (nopasswd "/run/current-system/sw/bin/rm /tmp/deploy-rs*")
          ];
        }
      ];

      users.groups.deploy = {};

      users.users.deploy.group = config.users.groups.deploy.name;
      users.users.deploy.isSystemUser = true;
      users.users.deploy.openssh.authorizedKeys.keys = cfg.users.deploy.authorizedKeys;
      users.users.deploy.shell = pkgs.bashInteractive;
    })

    (mkIf cfg.users.deploy.ciAccess {
      profian.users.deploy.authorizedKeys = cfg.ciKeys;
    })

    (mkIf cfg.users.haraldh.enable {
      environment.shells = with pkgs; [
        bashInteractive
      ];

      profian.users.deploy.authorizedKeys = cfg.users.haraldh.authorizedKeys;

      users.users.haraldh.isNormalUser = true;
      users.users.haraldh.extraGroups = cfg.adminGroups;
      users.users.haraldh.openssh.authorizedKeys.keys = cfg.users.haraldh.authorizedKeys;
      users.users.haraldh.shell = pkgs.bashInteractive;
    })

    (mkIf cfg.users.jarkko.enable {
      environment.shells = with pkgs; [
        bashInteractive
      ];

      users.users.jarkko.isNormalUser = true;
      users.users.jarkko.extraGroups = cfg.adminGroups;
      users.users.jarkko.openssh.authorizedKeys.keys = cfg.users.jarkko.authorizedKeys;
      users.users.jarkko.shell = pkgs.bashInteractive;
    })

    (mkIf cfg.users.npmccallum.enable {
      environment.shells = with pkgs; [
        bashInteractive
      ];

      profian.users.deploy.authorizedKeys = cfg.users.npmccallum.authorizedKeys;

      users.users.npmccallum.isNormalUser = true;
      users.users.npmccallum.extraGroups = cfg.adminGroups;
      users.users.npmccallum.openssh.authorizedKeys.keys = cfg.users.npmccallum.authorizedKeys;
      users.users.npmccallum.shell = pkgs.bashInteractive;
    })

    (mkIf cfg.users.puiterwijk.enable {
      environment.shells = with pkgs; [
        bashInteractive
      ];

      profian.users.deploy.authorizedKeys = cfg.users.puiterwijk.authorizedKeys;

      users.users.puiterwijk.isNormalUser = true;
      users.users.puiterwijk.extraGroups = cfg.adminGroups;
      users.users.puiterwijk.openssh.authorizedKeys.keys = cfg.users.puiterwijk.authorizedKeys;
      users.users.puiterwijk.shell = pkgs.bashInteractive;
    })

    (mkIf cfg.users.rvolosatovs.enable {
      programs.zsh.enable = true;

      profian.users.deploy.authorizedKeys = cfg.users.rvolosatovs.authorizedKeys;

      users.users.rvolosatovs.isNormalUser = true;
      users.users.rvolosatovs.extraGroups = cfg.adminGroups;
      users.users.rvolosatovs.openssh.authorizedKeys.keys = cfg.users.rvolosatovs.authorizedKeys;
      users.users.rvolosatovs.shell = pkgs.zsh;
    })
  ];
}
