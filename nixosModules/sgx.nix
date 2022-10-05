{...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  pccsServiceName = "${config.virtualisation.oci-containers.backend}-pccs";
  intelApiKeyFile = config.sops.secrets.intel-api-key.path;
in {
  boot.kernelModules = [
    "kvm-intel"
  ];
  boot.kernelPackages = pkgs.linuxPackages_enarx;

  hardware.cpu.intel.sgx.provision.enable = true;
  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "sgx";

  services.aesmd.enable = true;
  services.aesmd.qcnl.settings.pccsUrl = "https://127.0.0.1:8081/sgx/certification/v3/";
  services.aesmd.qcnl.settings.useSecureCert = false;

  services.enarx.backend = "sgx";

  services.pccs.apiKeyFile = intelApiKeyFile;
  services.pccs.enable = true;

  sops.secrets.intel-api-key.format = "binary";
  sops.secrets.intel-api-key.mode = "0000";
  sops.secrets.intel-api-key.restartUnits = [pccsServiceName];

  systemd.services.benefice.requires = [
    "${pccsServiceName}.service"
    "aesmd.service"
  ];

  systemd.services."${pccsServiceName}" = {
    preStart = lib.mkBefore ''
      chmod 0400 "${intelApiKeyFile}"
    '';
    postStop = lib.mkBefore ''
      chmod 0000 "${intelApiKeyFile}"
    '';
    serviceConfig.SupplementaryGroups = [config.users.groups.keys.name];
  };
}
