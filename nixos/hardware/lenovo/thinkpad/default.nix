{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ../../efi.nix
  ];

  config = mkMerge [
    {
      boot.extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
        wireguard
      ];

      boot.extraModprobeConfig = ''
        options thinkpad_acpi force-load=1
        options snd-hda-intel model=thinkpad
      '';
      boot.kernelModules = [
        "acpi_call"
      ];

      environment.systemPackages = with pkgs; [
        linuxPackages.acpi_call
        powertop
      ];

      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = false;
      hardware.cpu.intel.updateMicrocode = true;
      hardware.pulseaudio.enable = true;
      hardware.pulseaudio.package = pkgs.pulseaudioFull;

      security.polkit.extraConfig = ''
        /* https://wiki.archlinux.org/index.php/Fprint#Restrict_enrolling */
        polkit.addRule(function (action, subject) {
          if (action.id == "net.reactivated.fprint.device.enroll") {
            return subject.user == "root" ? polkit.Result.YES : polkit.result.NO
          }
        })
      '';

      services.acpid.enable = true;
      services.fprintd.enable = true;
      services.thermald.enable = true;
      services.thinkfan.sensor = "/sys/class/hwmon/hwmon0/temp1_input";
      services.upower.enable = true;

      services.tlp.enable = true;
      # See https://linrunner.de/en/tlp/docs/tlp-faq.html#battery https://wiki.archlinux.org/index.php/TLP#Btrfs
      services.tlp.extraConfig = ''
        SATA_LINKPWR_ON_BAT=max_performance

        # Battery health
        START_CHARGE_THRESH_BAT0=75
        STOP_CHARGE_THRESH_BAT0=90
        START_CHARGE_THRESH_BAT1=75
        STOP_CHARGE_THRESH_BAT1=90

        CPU_SCALING_GOVERNOR_ON_BAT=powersave
        ENERGY_PERF_POLICY_ON_BAT=powersave

        CPU_BOOST_ON_AC=0
        CPU_BOOST_ON_BAT=0
      '';
    }

    (mkIf config.services.xserver.enable {
      hardware.opengl.driSupport32Bit = true;
      hardware.opengl.enable = true;
      hardware.opengl.extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];

      hardware.trackpoint.emulateWheel = true;
      hardware.trackpoint.enable = true;
      hardware.trackpoint.sensitivity = 250;
      hardware.trackpoint.speed = 120;

      services.xserver.libinput.enable = true;
      services.xserver.libinput.middleEmulation = false;
      services.xserver.libinput.scrollButton = 1;
      services.xserver.videoDrivers = [
        "intel"
      ];
      services.xserver.xkbModel = "thinkpad60";
    })
  ];
}
