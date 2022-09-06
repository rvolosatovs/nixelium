{
  config,
  pkgs,
  ...
}: {
  services.udev.extraRules = ''
    # General
    KERNEL=="ttyACM*", OWNER="${config.resources.username}"
    KERNEL=="ttyUSB*", OWNER="${config.resources.username}"

    # OLKB kerboards
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="feed", OWNER="${config.resources.username}"

    # Planck Rev6 bootloader
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", OWNER="${config.resources.username}"

    # Keyboardio
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", OWNER="${config.resources.username}"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", OWNER="${config.resources.username}"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", OWNER="${config.resources.username}"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="230[0-3]", OWNER="${config.resources.username}"

    # Atmel ATMega32U4
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", OWNER="${config.resources.username}"

    # Atmel USBKEY AT90USB1287
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffb", OWNER="${config.resources.username}"

    # Atmel ATMega32U2
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff0", OWNER="${config.resources.username}"

    # SparkFun Pro Micro
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="920[34567]", ENV{ID_MM_DEVICE_IGNORE}="1", OWNER="${config.resources.username}"

    # Teensy
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", OWNER="${config.resources.username}"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"

    #
    # Debuggers
    #

    # Black Magic Probe
    SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic GDB Server"
    SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic UART Port"
  '';

  services.udev.packages = with pkgs; [
    openocd
  ];
}
