{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./../..
    ./../../../vendor/nixos-hardware/common/pc
    ./../../boards.nix
    ./../../graphical.nix
    ./../../mullvad.nix
    ./../../rtl-sdr.nix
    ./../../syncthing.nix
  ];

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];
  boot.kernelParams = [
    "systemd.unified_cgroup_hierarchy=1"
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.ControllerMode = "dual";
  hardware.bluetooth.powerOnBoot = true;

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.steam-hardware.enable = true;

  home-manager.users.${config.resources.username} = import ../../../home/profiles/pc;

  networking.useDHCP = false;
  networking.wireless.iwd.enable = true;

  programs.adb.enable = true;

  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.media-session.config.bluez-monitor.rules = [
    {
      matches = [{"device.name" = "~bluez_card.*";}];
      actions = {
        "update-props" = {
          "bluez5.reconnect-profiles" = ["hfp_hf" "hsp_hs" "a2dp_sink"];
          "bluez5.msbc-support" = true;
          "bluez5.sbc-xq-support" = true;
        };
      };
    }
    {
      matches = [
        {"node.name" = "~bluez_input.*";}
        {"node.name" = "~bluez_output.*";}
      ];
      actions = {
        "node.pause-on-idle" = false;
      };
    }
  ];
  services.pipewire.pulse.enable = true;

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    brlaser
  ];

  services.pcscd.enable = true;

  services.tailscale.enable = true;

  services.udev.packages = with pkgs; [
    android-udev-rules
    libu2f-host
    yubikey-personalization
    yubioath-desktop
  ];

  sound.mediaKeys.enable = true;

  systemd.services.audio-off.description = "Mute audio before suspend";
  systemd.services.audio-off.enable = true;
  systemd.services.audio-off.serviceConfig.ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
  systemd.services.audio-off.serviceConfig.RemainAfterExit = true;
  systemd.services.audio-off.serviceConfig.Type = "oneshot";
  systemd.services.audio-off.serviceConfig.User = config.resources.username;
  systemd.services.audio-off.wantedBy = ["sleep.target"];

  users.users.${config.resources.username}.extraGroups = [
    "adbusers"
  ];

  security.unprivilegedUsernsClone = true;
}
