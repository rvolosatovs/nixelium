{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.enarx;
in {
  options.services.enarx = {
    enable = mkEnableOption "Enarx support.";
    package = mkOption {
      type = types.package;
      default = pkgs.enarx;
      defaultText = literalExpression "pkgs.enarx";
      description = "Enarx package to use.";
    };
    log.level = mkOption {
      type = with types; nullOr (enum ["trace" "debug" "info" "warn" "error"]);
      default = null;
      example = "debug";
      description = "Log level to use, if unset the default value is used.";
    };
    backend = mkOption {
      type = with types; nullOr (enum ["nil" "kvm" "sgx" "sev"]);
      default = null;
      description = "Enarx backend to use. If null, services will run as root user and backend will be chosen by the binary at runtime.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd.services."enarx@".after = ["systemd-udevd.service"];
      systemd.services."enarx@".environment.ENARX_BACKEND = cfg.backend;
      systemd.services."enarx@".environment.RUST_LOG = cfg.log.level;
      systemd.services."enarx@".serviceConfig.ExecStart = "${cfg.package}/bin/enarx deploy %I";
      systemd.services."enarx@".serviceConfig.KeyringMode = "private";
      systemd.services."enarx@".serviceConfig.LockPersonality = true;
      systemd.services."enarx@".serviceConfig.NoNewPrivileges = true;
      systemd.services."enarx@".serviceConfig.PrivateMounts = "yes";
      systemd.services."enarx@".serviceConfig.PrivateTmp = "yes";
      systemd.services."enarx@".serviceConfig.ProtectClock = true;
      systemd.services."enarx@".serviceConfig.ProtectControlGroups = "yes";
      systemd.services."enarx@".serviceConfig.ProtectHome = true;
      systemd.services."enarx@".serviceConfig.ProtectHostname = true;
      systemd.services."enarx@".serviceConfig.ProtectKernelLogs = true;
      systemd.services."enarx@".serviceConfig.ProtectKernelModules = true;
      systemd.services."enarx@".serviceConfig.ProtectKernelTunables = true;
      systemd.services."enarx@".serviceConfig.ProtectProc = "invisible";
      systemd.services."enarx@".serviceConfig.ProtectSystem = "strict";
      systemd.services."enarx@".serviceConfig.RemoveIPC = true;
      systemd.services."enarx@".serviceConfig.Restart = "on-failure";
      systemd.services."enarx@".serviceConfig.RestrictNamespaces = true;
      systemd.services."enarx@".serviceConfig.RestrictRealtime = true;
      systemd.services."enarx@".serviceConfig.RestrictSUIDSGID = true;
      systemd.services."enarx@".serviceConfig.SystemCallArchitectures = "native";
      systemd.services."enarx@".serviceConfig.Type = "exec";
      systemd.services."enarx@".serviceConfig.UMask = "0077";
    }
    (mkIf (isNull cfg.backend) {
      systemd.services."enarx@".serviceConfig.DeviceAllow = [
        "/dev/kvm rw"
        "/dev/sev rw"
        "/dev/sgx_enclave rw"
      ];
    })
    (mkIf (!isNull cfg.backend) {
      systemd.services."enarx@".serviceConfig.DynamicUser = true;
      systemd.services."enarx@".serviceConfig.Group = "enarx";
    })
    (mkIf (cfg.backend == "sgx") {
      assertions = [
        {
          assertion = config.hardware.cpu.intel.sgx.provision.enable;
          message = "Intel SGX support is not enabled";
        }
      ];

      systemd.services.sgx-register.after = ["systemd-udevd.service"];
      systemd.services.sgx-register.before = ["enarx@.service"];
      systemd.services.sgx-register.description = "Register Intel SGX";
      systemd.services.sgx-register.serviceConfig.DeviceAllow = "/dev/sgx_provision rw";
      systemd.services.sgx-register.serviceConfig.DynamicUser = true;
      systemd.services.sgx-register.serviceConfig.ExecStart = "${cfg.package}/bin/enarx platform sgx register";
      systemd.services.sgx-register.serviceConfig.Group = "sgx-register";
      systemd.services.sgx-register.serviceConfig.KeyringMode = "private";
      systemd.services.sgx-register.serviceConfig.LockPersonality = true;
      systemd.services.sgx-register.serviceConfig.MemoryDenyWriteExecute = true;
      systemd.services.sgx-register.serviceConfig.NoNewPrivileges = true;
      systemd.services.sgx-register.serviceConfig.PrivateMounts = "yes";
      systemd.services.sgx-register.serviceConfig.PrivateTmp = "yes";
      systemd.services.sgx-register.serviceConfig.ProtectClock = true;
      systemd.services.sgx-register.serviceConfig.ProtectControlGroups = "yes";
      systemd.services.sgx-register.serviceConfig.ProtectHome = true;
      systemd.services.sgx-register.serviceConfig.ProtectHostname = true;
      systemd.services.sgx-register.serviceConfig.ProtectKernelLogs = true;
      systemd.services.sgx-register.serviceConfig.ProtectKernelModules = true;
      systemd.services.sgx-register.serviceConfig.ProtectKernelTunables = true;
      systemd.services.sgx-register.serviceConfig.ProtectProc = "invisible";
      systemd.services.sgx-register.serviceConfig.ProtectSystem = "strict";
      systemd.services.sgx-register.serviceConfig.RemoveIPC = true;
      systemd.services.sgx-register.serviceConfig.RestrictNamespaces = true;
      systemd.services.sgx-register.serviceConfig.RestrictRealtime = true;
      systemd.services.sgx-register.serviceConfig.RestrictSUIDSGID = true;
      systemd.services.sgx-register.serviceConfig.SupplementaryGroups = config.hardware.cpu.intel.sgx.provision.group;
      systemd.services.sgx-register.serviceConfig.SystemCallArchitectures = "native";
      systemd.services.sgx-register.serviceConfig.Type = "oneshot";
      systemd.services.sgx-register.serviceConfig.UMask = "0077";
      systemd.services.sgx-register.unitConfig.ConditionPathExists = "/dev/sgx_provision";
      systemd.services.sgx-register.wantedBy = ["multi-user.target"];

      systemd.services."enarx@".serviceConfig.DeviceAllow = "/dev/sgx_enclave rw";
      systemd.services."enarx@".serviceConfig.SupplementaryGroups = "sgx"; # owner group of /dev/sgx_enclave
      systemd.services."enarx@".unitConfig.ConditionPathExists = "/dev/sgx_enclave";
    })
    (mkIf (cfg.backend == "sev") {
      assertions = [
        {
          assertion = config.hardware.cpu.amd.sev.enable;
          message = "AMD SEV-SNP support is not enabled";
        }
      ];

      systemd.services."enarx@".serviceConfig.DeviceAllow = [
        "/dev/kvm rw"
        "/dev/sev rw"
      ];
      systemd.services."enarx@".serviceConfig.LimitMEMLOCK = "8G";
      systemd.services."enarx@".serviceConfig.SupplementaryGroups = config.hardware.cpu.amd.sev.group;
      systemd.services."enarx@".unitConfig.ConditionPathExists = [
        "/dev/kvm"
        "/dev/sev"
      ];

      # NOTE: these two services should be separated from Enarx in the future.

      systemd.services.amd-sev-cache.before = ["vcek-update.service"];
      systemd.services.amd-sev-cache.description = "AMD SEV cache directory";
      systemd.services.amd-sev-cache.script = ''
        mkdir -pv /var/cache/amd-sev
        chown -R root:${config.hardware.cpu.amd.sev.group} /var/cache/amd-sev
        chmod 775 /var/cache/amd-sev
        chmod 664 /var/cache/amd-sev/vcek-*
      '';
      systemd.services.amd-sev-cache.serviceConfig.Type = "oneshot";
      systemd.services.amd-sev-cache.wantedBy = ["vcek-update.service"];

      systemd.services.vcek-update.after = ["systemd-udevd.service"];
      systemd.services.vcek-update.before = ["enarx@.service"];
      systemd.services.vcek-update.description = "Update AMD SEV-SNP VCEK";
      systemd.services.vcek-update.serviceConfig.DeviceAllow = "/dev/sev rw";
      systemd.services.vcek-update.serviceConfig.DynamicUser = true;
      systemd.services.vcek-update.serviceConfig.ExecStart = "${cfg.package}/bin/enarx platform snp update";
      systemd.services.vcek-update.serviceConfig.Group = "vcek-update";
      systemd.services.vcek-update.serviceConfig.KeyringMode = "private";
      systemd.services.vcek-update.serviceConfig.LockPersonality = true;
      systemd.services.vcek-update.serviceConfig.MemoryDenyWriteExecute = true;
      systemd.services.vcek-update.serviceConfig.NoNewPrivileges = true;
      systemd.services.vcek-update.serviceConfig.PrivateMounts = "yes";
      systemd.services.vcek-update.serviceConfig.PrivateTmp = "yes";
      systemd.services.vcek-update.serviceConfig.ProtectClock = true;
      systemd.services.vcek-update.serviceConfig.ProtectControlGroups = "yes";
      systemd.services.vcek-update.serviceConfig.ProtectHome = true;
      systemd.services.vcek-update.serviceConfig.ProtectHostname = true;
      systemd.services.vcek-update.serviceConfig.ProtectKernelLogs = true;
      systemd.services.vcek-update.serviceConfig.ProtectKernelModules = true;
      systemd.services.vcek-update.serviceConfig.ProtectKernelTunables = true;
      systemd.services.vcek-update.serviceConfig.ProtectProc = "invisible";
      systemd.services.vcek-update.serviceConfig.ProtectSystem = "strict";
      systemd.services.vcek-update.serviceConfig.RemoveIPC = true;
      systemd.services.vcek-update.serviceConfig.RestrictNamespaces = true;
      systemd.services.vcek-update.serviceConfig.RestrictRealtime = true;
      systemd.services.vcek-update.serviceConfig.RestrictSUIDSGID = true;
      systemd.services.vcek-update.serviceConfig.SupplementaryGroups = config.hardware.cpu.amd.sev.group;
      systemd.services.vcek-update.serviceConfig.SystemCallArchitectures = "native";
      systemd.services.vcek-update.serviceConfig.Type = "oneshot";
      systemd.services.vcek-update.serviceConfig.UMask = "0077";
      systemd.services.vcek-update.unitConfig.ConditionPathExists = "/dev/sev";
      systemd.services.vcek-update.wantedBy = ["multi-user.target"];
    })
  ]);
}
