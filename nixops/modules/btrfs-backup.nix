{ config, pkgs, lib, utils, ... }:

with lib;

let
  cfg = config.services.btrfs.snapshotBackup;

  mkEscapedPath = subvol: utils.escapeSystemdPath subvol.path;

  mkBackupName = subvol: "${mkEscapedPath subvol}@";
  mkSystemdServiceName = subvol: "btrfs-backup-${mkBackupName subvol}";
  mkSystemdPathName = subvol: "btrfs-backup-${mkEscapedPath subvol}";
  mkPasswordName = subvol: "btrfs-backup-${mkEscapedPath subvol}-password";
  mkSSHKeyName = subvol: "btrfs-backup-${mkEscapedPath subvol}-ssh";

  # TODO: Extract this into a generic function.
  mkSecretPath = mkName: subvol: if config.deployment.storeKeysOnMachine then "/etc/${config.environment.etc."keys/${mkName subvol}".target}" else config.deployment.keys.${mkName subvol}.path;

  mkPasswordPath = subvol: mkSecretPath mkPasswordName subvol;
in
  {
    options = {
      services.btrfs.snapshotBackup = {
        enable = mkEnableOption "BTRFS snapshot backup";

        subvolumes = mkOption {
          default = {};
          type = types.attrsOf (types.submodule ({ name, ... }: {
            options = {
              path = mkOption {
                example = "/.snapshots";
                default = name;
                type = types.str;
                description = "Path containing subvolume snapshots.";
              };

              repository = mkOption {
                example = "sftp://restic@192.168.1.100:1234//var/lib/restic/foo";
                type = types.str;
                description = "Restic repository to backup subvolume snapshots to.";
              };

              passwordFile = mkOption {
                example = "/path/to/password";
                type = types.path;
                description = "The file containing the Restic repository password.";
              };

              ssh = mkOption {
                default = null;
                type = types.nullOr (types.submodule {
                  options = {
                    key = mkOption {
                      type = types.str;
                      description = "The SSH private key used to access the Restic repository.";
                    };
                  };
                });
              };
            };
          }));
        };
      };
    };

    config = mkIf cfg.enable (mkMerge [
      {
        services.restic.backups = mapAttrs' (_: subvol: nameValuePair (mkBackupName subvol) {
          inherit (subvol) repository;
          timerConfig = {};
          extraOptions = optional (ssh != null && ssh.key != "") "sftp.command='${mkSFTPCommand subvol}'";
          preHook = ''
            archiveName="${config.networking.hostName}-''${1}"
            if [ "$(borg list $extraArgs -a "''${archiveName}''${archiveSuffix}")" ]; then
              borg delete $extraArgs "::''${archiveName}''${archiveSuffix}"
            fi
            if [ "$(borg list $extraArgs -a "''${archiveName}")" ]; then
              exit 0
            fi
            cd "${subvol.path}/''${1}/snapshot"
          '';
          prune.keep = {
            within = "2d";
            daily = 20;
          };
          startAt = [];
        }) cfg.subvolumes;

        services.borgbackup.jobs = mapAttrs' (_: subvol: nameValuePair (mkBackupName subvol) {
          inherit (subvol) repo;
          archiveBaseName = config.networking.hostName;
          compression = "auto,zstd,9";
          encryption.mode = "repokey-blake2";
          encryption.passCommand = mkPassCommand subvol;
          environment = mkIf (subvol.ssh != null) {
            BORG_RSH = mkSSHCommand subvol;
          };
          paths = ".";
          preHook = ''
            archiveName="${config.networking.hostName}-''${1}"
            if [ "$(borg list $extraArgs -a "''${archiveName}''${archiveSuffix}")" ]; then
              borg delete $extraArgs "::''${archiveName}''${archiveSuffix}"
            fi
            if [ "$(borg list $extraArgs -a "''${archiveName}")" ]; then
              exit 0
            fi
            cd "${subvol.path}/''${1}/snapshot"
          '';
          prune.keep = {
            within = "2d";
            daily = 20;
          };
          startAt = [];
        }) cfg.subvolumes;

        systemd = mkMerge (mapAttrsToList (_: subvol: {
          paths.${mkSystemdPathName subvol} = {
            pathConfig.PathChanged = subvol.path;
            wantedBy = [ "multi-user.target" ];
          };
          services.${mkSystemdPathName subvol} = {
            script = ''
              cd "${subvol.path}"
              for d in *; do
                systemctl start --wait "${mkSystemdServiceName subvol}''${d}.service"
              done
            '';
            wantedBy = [ "multi-user.target" ];
          };

          services.${mkSystemdServiceName subvol} = {
            script = ''
              cd ${subvol.path}
              RESTIC_PASSWORD_FILE=${subvol.passwordFile} ${pkgs.restic}/bin/restic -r ${subvol.repository} backup ${
                optionalString (subvol.ssh != null && subvol.ssh.key != null) "-o sftp.command='${pkgs.openssh}/bin/ssh -s sftp -i ${mkSecretPath mkSSHKeyName subvol}'"
              } ./%I
            '';
            scriptArgs = "%I";
          };
        }) cfg.subvolumes);
      }

      (mkIf config.deployment.storeKeysOnMachine {
        environment.etc = mkMerge (mapAttrsToList (_: subvol: let
          mkKey = text: {
            inherit (config.services.borgbackup.jobs.${mkJobName subvol}) user group;
            inherit text;
            mode = "0600";
          };
        in
          {
          "keys/${mkPasswordName subvol}" = mkKey subvol.passphrase;
          "keys/${mkSSHKeyName subvol}" = mkIf (subvol.ssh != null && subvol.ssh.key != "") (mkKey subvol.ssh.key);
        }) cfg.subvolumes);
      })

      (mkIf (!config.deployment.storeKeysOnMachine) {
        deployment.keys = mkMerge (mapAttrsToList (_: subvol: let
          mkKey = text: {
            inherit (config.services.borgbackup.jobs.${mkJobName subvol}) user group;
            inherit text;
          };
        in
          {
          "${mkPasswordName subvol}" = mkKey subvol.passphrase;
          "${mkSSHKeyName subvol}" = mkIf (subvol.ssh != null && subvol.ssh.key != "") (mkKey subvol.ssh.key);
        }) cfg.subvolumes);

        systemd.services = mkMerge (mapAttrsToList (_: subvol: {
          ${mkSystemdServiceName subvol} = let
            keyDeps = [ "${mkPasswordName subvol}-key.service" ] ++ optional (subvol.ssh != null && subvol.ssh.key != "") "${mkSSHKeyName subvol}-key.service";
          in {
            after = keyDeps;
            wants = keyDeps;
          };
        }) cfg.subvolumes);

        users.users = mapAttrs' (_: subvol: nameValuePair config.services.borgbackup.jobs.${mkJobName subvol}.user { extraGroups = [ "keys" ]; }) cfg.subvolumes;
      })
    ]);
  }
