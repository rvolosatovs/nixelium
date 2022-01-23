{ config, pkgs, ... }:
{
  imports = [
    ./../..
    ./../../../vendor/nixos-hardware/common/pc
    ./../../boards.nix
    ./../../graphical.nix
    ./../../mullvad.nix
    ./../../rtl-sdr.nix
    ./../../syncthing.nix
  ];

  boot.kernelParams = [
    "systemd.unified_cgroup_hierarchy=1"
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.ControllerMode = "dual";
  hardware.bluetooth.powerOnBoot = true;

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.tcp.anonymousClients.allowedIpRanges = [ "127.0.0.1" ];
  hardware.pulseaudio.tcp.enable = true;

  hardware.steam-hardware.enable = true;

  home-manager.users.${config.resources.username} = import ../../../home/profiles/pc;

  networking.useDHCP = false;
  networking.wireless.iwd.enable = true;

  programs.adb.enable = true;

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    brlaser
  ];

  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [
    libu2f-host
    yubikey-personalization
    yubioath-desktop
  ];

  sound.enable = true;
  sound.mediaKeys.enable = true;

  systemd.services.audio-off.description = "Mute audio before suspend";
  systemd.services.audio-off.enable = true;
  systemd.services.audio-off.serviceConfig.ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
  systemd.services.audio-off.serviceConfig.RemainAfterExit = true;
  systemd.services.audio-off.serviceConfig.Type = "oneshot";
  systemd.services.audio-off.serviceConfig.User = config.resources.username;
  systemd.services.audio-off.wantedBy = [ "sleep.target" ];

  users.users.${config.resources.username}.extraGroups = [
    "adbusers"
  ];

  security.unprivilegedUsernsClone = true;
}
