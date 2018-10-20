{ config, pkgs, ... }:
{
  imports = [
    ./../..
    ./../../../vendor/nixos-hardware/common/pc/laptop
    ./../../boards.nix
    ./../../graphical.nix
    #./../../mopidy.nix
    #./../../virtualbox.nix
  ];

  hardware.pulseaudio.tcp.enable = true;
  hardware.pulseaudio.tcp.anonymousClients.allowedIpRanges = [ "127.0.0.1" ];

  home-manager.users.${config.resources.username} = {...}: {
    imports = [
      ../../../home/profiles/laptop
      ../../../vendor/secrets/home
    ];
  };

  programs.adb.enable = true;

  services.printing.enable = true;

  sound.enable = true;
  sound.mediaKeys.enable = true;

  systemd.services.audio-off.description = "Mute audio before suspend";
  systemd.services.audio-off.enable = true;
  systemd.services.audio-off.serviceConfig.ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
  systemd.services.audio-off.serviceConfig.RemainAfterExit = true;
  systemd.services.audio-off.serviceConfig.Type = "oneshot";
  systemd.services.audio-off.serviceConfig.User = "${config.resources.username}";
  systemd.services.audio-off.wantedBy = [ "sleep.target" ];

  users.users.${config.resources.username}.extraGroups = [
    "adbusers"
  ];
}
