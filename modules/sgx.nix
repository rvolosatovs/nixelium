{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hardware.cpu.intel.sgx;

  backend = config.virtualisation.oci-containers.backend;

  aesmdService = "${backend}-aesmd";

  aesmdImageName = "registry.gitlab.com/enarx/aesmd";
  aesmd = pkgs.dockerTools.pullImage {
    imageName = aesmdImageName;
    imageDigest = "sha256:7d9016e8a274b2873d99b21ef34b8db1c869c0c96edad68e53efd7688561fa1a";
    sha256 = "11205ka4ws2mv4788fhbilzgq31ag4swsc3r7bkkzz9gqq74i7l2";
  };

  defaultAesmdGroup = "aesmd";

  pccsService = "${backend}-pccs";

  pccsImageName = "registry.gitlab.com/haraldh/pccs";
  pccs = pkgs.dockerTools.pullImage {
    imageName = pccsImageName;
    imageDigest = "sha256:b0729c0588a124c23d1c8d53d1ccd4f3d4ac099afc46e3fa8e5e0da9738bc760";
    sha256 = "0xgxq82j3x2j21m2xzq5rwckn28n9ym6cfivaxadry6a9wpi40xr";
    finalImageTag = "working";
  };

  defaultPccsGroup = "pccs";
in
  with lib; {
    options.hardware.cpu.intel.sgx.aesmd = {
      enable = mkEnableOption "Intel SGX Attestation Daemon service.";
      user = mkOption {
        type = types.str;
        default = "root";
        description = "User to run the Intel SGX Attestation Daemon service as.";
      };
      group = mkOption {
        type = types.str;
        default = defaultAesmdGroup;
        description = "Group to run the Intel SGX Attestation Daemon service as.";
      };
    };

    options.hardware.cpu.intel.sgx.provision.service = {
      enable = mkEnableOption "Intel SGX Provisioning Certification service.";
      user = mkOption {
        type = types.str;
        default = "root";
        description = "User to run the Intel SGX Provisioning Certification service as.";
      };
      group = mkOption {
        type = types.str;
        default = defaultPccsGroup;
        description = "Group to run the Intel SGX Provisioning Certification service as.";
      };
      apiKey = mkOption {
        type = types.str;
        description = "Path to SGX API key.";
      };
    };

    config = mkMerge [
      (mkIf cfg.aesmd.enable {
        assertions = [
          {
            assertion = hasAttr cfg.aesmd.user config.users.users;
            message = "Given user does not exist";
          }
          {
            assertion = (cfg.aesmd.group == defaultAesmdGroup) || (hasAttr cfg.aesmd.group config.users.groups);
            message = "Given group does not exist";
          }
        ];

        systemd.services.${aesmdService} = {
          serviceConfig.Group = cfg.aesmd.group;
          serviceConfig.LimitMEMLOCK = "8G";
          serviceConfig.Restart = "always";
          serviceConfig.Type = "exec";
          serviceConfig.User = cfg.aesmd.user;
        };

        users.groups = optionalAttrs (cfg.aesmd.group == defaultAesmdGroup) {
          "${cfg.aesmd.group}" = {};
        };

        virtualisation.oci-containers.containers.aesmd.extraOptions = ["--device=/dev/sgx_enclave"];
        virtualisation.oci-containers.containers.aesmd.image = aesmdImageName;
        virtualisation.oci-containers.containers.aesmd.imageFile = aesmd;
        virtualisation.oci-containers.containers.aesmd.volumes = [
          "/dev/sgx_enclave:/dev/sgx/enclave"
          "/dev/sgx_provision:/dev/sgx/provision"
          "/var/run/aesmd:/var/run/aesmd"
        ];
      })
      (mkIf cfg.provision.service.enable {
        assertions = [
          {
            assertion = hasAttr cfg.provision.service.user config.users.users;
            message = "Given user does not exist";
          }
          {
            assertion = (cfg.provision.service.group == defaultPccsGroup) || (hasAttr cfg.provision.service.group config.users.groups);
            message = "Given group does not exist";
          }
        ];

        systemd.services.${pccsService} = {
          preStart = ''
            ${backend} secret create PCCS_APIKEY ${cfg.provision.service.apiKey}
          '';
          postStop = ''
            ${backend} secret rm PCCS_APIKEY
          '';
          serviceConfig.Group = cfg.provision.service.group;
          serviceConfig.LimitMEMLOCK = "8G";
          serviceConfig.Restart = "always";
          serviceConfig.Type = "exec";
          serviceConfig.User = cfg.provision.service.user;
        };

        users.groups = optionalAttrs (cfg.provision.service.group == defaultPccsGroup) {
          "${cfg.provision.service.group}" = {};
        };

        virtualisation.oci-containers.containers.pccs.extraOptions = [
          "--network=host"
          "--secret=PCCS_APIKEY,type=mount"
        ];
        virtualisation.oci-containers.containers.pccs.image = pccsImageName;
        virtualisation.oci-containers.containers.pccs.imageFile = pccs;
      })
    ];
  }
