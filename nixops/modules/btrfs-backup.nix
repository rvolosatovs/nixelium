{ config, pkgs, lib, utils, ... }:

with lib;

let
  cfg = config.services.btrfs.snapshotBackup;

  mkEscapedPath = subvol: utils.escapeSystemdPath subvol.path;

  mkJobName = subvol: "${mkEscapedPath subvol}@";
  mkJobServiceName = subvol: "borgbackup-job-${mkJobName subvol}";

  mkRepoKeyName = subvol: "btrfs-backup-${mkEscapedPath subvol}-repo";
  mkSSHKeyName = subvol: "btrfs-backup-${mkEscapedPath subvol}-ssh";
  mkPathName = subvol: "btrfs-backup-${mkEscapedPath subvol}";

  # TODO: Extract this into a generic function.
  mkSecretPath = mkName: subvol: if config.deployment.storeKeysOnMachine then "/etc/${config.environment.etc."keys/${mkName subvol}".target}" else config.deployment.keys.${mkName subvol}.path;

  mkPassCommand = subvol: "cat ${mkSecretPath mkRepoKeyName subvol}";
  mkSSHCommand = subvol: "${pkgs.openssh}/bin/ssh" + optionalString (subvol.ssh != null && subvol.ssh.key != null) " -i ${mkSecretPath mkSSHKeyName subvol}";
in
{
  options = {
    services.btrfs.snapshotBackup = {
      enable = mkEnableOption "BTRFS snapshot backup";

      subvolumes = mkOption {
        default = { };
        type = types.attrsOf (types.submodule ({ name, ... }: {
          options = {
            path = mkOption {
              example = "/.snapshots";
              default = name;
              type = types.str;
              description = "Path containing subvolume snapshots.";
            };

            repo = mkOption {
              example = "/var/lib/borgbackup/foo";
              type = types.str;
              description = "Path to borgbackup repo to backup subvolume snapshots to.";
            };

            passphrase = mkOption {
              example = "test-password";
              type = types.str;
              description = "The passphrase the backups are encrypted with.";
            };

            ssh = mkOption {
              default = null;
              type = types.nullOr (types.submodule {
                options = {
                  key = mkOption {
                    type = types.str;
                    description = "The SSH private key used to access the repo.";
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
      services.borgbackup.jobs = mapAttrs'
        (_: subvol: nameValuePair (mkJobName subvol) {
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
          startAt = [ ];
        })
        cfg.subvolumes;

      systemd = mkMerge (mapAttrsToList
        (_: subvol: {
          paths.${mkPathName subvol} = {
            pathConfig.PathChanged = subvol.path;
            wantedBy = [ "multi-user.target" ];
          };
          services.${mkPathName subvol} = {
            script = ''
              cd "${subvol.path}"
              for d in *; do
                systemctl start --wait "${mkJobServiceName subvol}''${d}.service"
              done
            '';
            wantedBy = [ "multi-user.target" ];
          };
          services.${mkJobServiceName subvol}.scriptArgs = "%I";
        })
        cfg.subvolumes);
    }

    (mkIf config.deployment.storeKeysOnMachine {
      environment.etc = mkMerge (mapAttrsToList
        (_: subvol:
          let
            mkKey = text: {
              inherit (config.services.borgbackup.jobs.${mkJobName subvol}) user group;
              inherit text;
              mode = "0600";
            };
          in
          {
            "keys/${mkRepoKeyName subvol}" = mkKey subvol.passphrase;
            "keys/${mkSSHKeyName subvol}" = mkIf (subvol.ssh != null && subvol.ssh.key != "") (mkKey subvol.ssh.key);
          })
        cfg.subvolumes);
    })

    (mkIf (!config.deployment.storeKeysOnMachine) {
      deployment.keys = mkMerge (mapAttrsToList
        (_: subvol:
          let
            mkKey = text: {
              inherit (config.services.borgbackup.jobs.${mkJobName subvol}) user group;
              inherit text;
            };
          in
          {
            "${mkRepoKeyName subvol}" = mkKey subvol.passphrase;
            "${mkSSHKeyName subvol}" = mkIf (subvol.ssh != null && subvol.ssh.key != "") (mkKey subvol.ssh.key);
          })
        cfg.subvolumes);

      systemd.services = mkMerge (mapAttrsToList
        (_: subvol: {
          ${mkJobServiceName subvol} =
            let
              keyDeps = [ "${mkRepoKeyName subvol}-key.service" ] ++ optional (subvol.ssh != null && subvol.ssh.key != "") "${mkSSHKeyName subvol}-key.service";
            in
            {
              after = keyDeps;
              wants = keyDeps;
            };
        })
        cfg.subvolumes);

      users.users = mapAttrs' (_: subvol: nameValuePair config.services.borgbackup.jobs.${mkJobName subvol}.user { extraGroups = [ "keys" ]; }) cfg.subvolumes;
    })
  ]);
}
