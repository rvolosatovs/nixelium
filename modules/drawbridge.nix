{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.drawbridge;

  defaultGroup = "drawbridge";
  defaultStore = "/var/lib/drawbridge";

  certs = config.security.acme.certs.${config.networking.fqdn}.directory;

  conf.toml =
    ''
      ca = "${cfg.tls.ca}"
      cert = "${certs}/cert.pem"
      key = "${certs}/key.pem"
      oidc-client = "${cfg.oidc.client}"
      oidc-issuer = "${cfg.oidc.issuer}"
      oidc-label = "${cfg.oidc.label}"
      store = "${cfg.store.path}"
    ''
    + optionalString (cfg.oidc.secret != null) ''oidc-secret = "${cfg.oidc.secret}"'';

  configFile = pkgs.writeText "conf.toml" conf.toml;
in {
  options.services.drawbridge = {
    enable = mkEnableOption "Drawbridge service.";
    package = mkOption {
      type = types.package;
      default = pkgs.drawbridge;
      defaultText = literalExpression "pkgs.drawbridge";
      description = "Drawbridge package to use.";
    };
    group = mkOption {
      type = types.str;
      default = defaultGroup;
      description = "Group to run the Drawbridge service as.";
    };
    log.level = mkOption {
      type = with types; nullOr (enum ["trace" "debug" "info" "warn" "error"]);
      default = null;
      example = "debug";
      description = "Log level to use, if unset the default value is used.";
    };
    oidc.client = mkOption {
      type = types.str;
      example = "2vq9XnQgcGZ9JCxsGERuGURYIld3mcIh";
      description = "OpenID Connect client ID to use.";
    };
    oidc.secret = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "/var/lib/drawbridge/oidc-secret";
      description = "Path to OpenID Connect client secret.";
    };
    oidc.issuer = mkOption {
      type = types.strMatching "(http|https)://.+";
      default = "https://auth.profian.com";
      example = "https://auth.example.com";
      description = "OpenID Connect issuer URL.";
    };
    oidc.label = mkOption {
      type = types.str;
      default = "auth.profian.com";
      example = "auth.example.com";
      description = "OpenID Connect issuer label to use in the store internally.";
    };
    store.path = mkOption {
      type = types.path;
      default = defaultStore;
      description = "Path to Drawbridge store.";
    };
    store.create = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Wheter to create the Drawbridge store.

        When <literal>true</literal>, "${cfg.store.path}" will be created and used
        with 0770 permissions owned by `root:${cfg.group}`.
      '';
    };
    tls.ca = mkOption {
      type = types.path;
      description = ''
        Path to a CA certificate, client certificates signed by which will
        grant global read-only access to all packages in the Drawbridge.

        This is normally a Steward CA certificate.
      '';
      example = literalExpression "./path/to/ca.crt";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = config.services.nginx.enable;
          message = "Nginx service is not enabled";
        }
        {
          assertion = (cfg.group == defaultGroup) || (hasAttr cfg.group config.users.groups);
          message = "Given group does not exist";
        }
      ];

      environment.systemPackages = [
        cfg.package
      ];

      services.nginx.virtualHosts.${config.networking.fqdn} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "https://localhost:8080";
        recommendedTlsSettings = true;
        sslCiphers = lib.concatStringsSep ":" [
          "ECDHE-ECDSA-AES256-GCM-SHA384"
          "ECDHE-ECDSA-AES128-GCM-SHA256"
          "ECDHE-ECDSA-CHACHA20-POLY1305"
        ];
        sslProtocols = "TLSv1.3";
        sslTrustedCertificate = cfg.tls.ca;
        extraConfig = ''
          proxy_ssl_protocols TLSv1.3;
        '';
      };

      systemd.services.drawbridge.after = [
        "network-online.target"
      ];
      systemd.services.drawbridge.description = "Drawbridge";
      systemd.services.drawbridge.environment.RUST_LOG = cfg.log.level;
      systemd.services.drawbridge.serviceConfig.DeviceAllow = "";
      systemd.services.drawbridge.serviceConfig.DynamicUser = true;
      systemd.services.drawbridge.serviceConfig.ExecStart = "${cfg.package}/bin/drawbridge @${configFile}";
      systemd.services.drawbridge.serviceConfig.Group = cfg.group;
      systemd.services.drawbridge.serviceConfig.KeyringMode = "private";
      systemd.services.drawbridge.serviceConfig.LockPersonality = true;
      systemd.services.drawbridge.serviceConfig.NoNewPrivileges = true;
      systemd.services.drawbridge.serviceConfig.PrivateDevices = true;
      systemd.services.drawbridge.serviceConfig.PrivateMounts = "yes";
      systemd.services.drawbridge.serviceConfig.PrivateTmp = "yes";
      systemd.services.drawbridge.serviceConfig.ProtectClock = true;
      systemd.services.drawbridge.serviceConfig.ProtectControlGroups = "yes";
      systemd.services.drawbridge.serviceConfig.ProtectHome = true;
      systemd.services.drawbridge.serviceConfig.ProtectHostname = true;
      systemd.services.drawbridge.serviceConfig.ProtectKernelLogs = true;
      systemd.services.drawbridge.serviceConfig.ProtectKernelModules = true;
      systemd.services.drawbridge.serviceConfig.ProtectKernelTunables = true;
      systemd.services.drawbridge.serviceConfig.ProtectProc = "invisible";
      systemd.services.drawbridge.serviceConfig.ProtectSystem = "strict";
      systemd.services.drawbridge.serviceConfig.ReadWritePaths = cfg.store.path;
      systemd.services.drawbridge.serviceConfig.RemoveIPC = true;
      systemd.services.drawbridge.serviceConfig.Restart = "always";
      systemd.services.drawbridge.serviceConfig.RestrictNamespaces = true;
      systemd.services.drawbridge.serviceConfig.RestrictRealtime = true;
      systemd.services.drawbridge.serviceConfig.RestrictSUIDSGID = true;
      systemd.services.drawbridge.serviceConfig.SupplementaryGroups = config.services.nginx.group;
      systemd.services.drawbridge.serviceConfig.SystemCallArchitectures = "native";
      systemd.services.drawbridge.serviceConfig.Type = "exec";
      systemd.services.drawbridge.serviceConfig.UMask = "0007";
      systemd.services.drawbridge.unitConfig.ConditionPathExists = cfg.store.path;
      systemd.services.drawbridge.wantedBy = ["multi-user.target"];
      systemd.services.drawbridge.wants = ["network-online.target"];

      users.groups = optionalAttrs (cfg.group == defaultGroup) {
        "${cfg.group}" = {};
      };
    }
    (mkIf cfg.store.create {
      systemd.services.drawbridge-store.before = ["drawbridge.service"];
      systemd.services.drawbridge-store.description = "Drawbridge store directory";
      systemd.services.drawbridge-store.script = ''
        mkdir -pv ${cfg.store.path}
        chown -R root:${cfg.group} ${cfg.store.path}
        chmod 0770 ${cfg.store.path}
      '';
      systemd.services.drawbridge-store.serviceConfig.Group = cfg.group;
      systemd.services.drawbridge-store.serviceConfig.Type = "oneshot";
      systemd.services.drawbridge-store.serviceConfig.UMask = "0007";
      systemd.services.drawbridge-store.wantedBy = ["drawbridge.service"];
    })
  ]);
}
