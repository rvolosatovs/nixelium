{ config, pkgs, lib, ...}:

with lib;

{
  programs = {
    ssh = {
      askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      #startAgent = true;
    };

    adb.enable = true;
    light.enable = true;
    java.enable = true;
    wireshark.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    browserpass.enable = true;

    chromium = {
      enable = true;
      extensions = [
        "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
        "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
        "jegbgfamcgeocbfeebacnkociplhmfbk" # browserpass
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    linuxPackages.acpi_call
    acpi
    powertop
    microcodeIntel
    libnotify

    # X11
    xdo
    wmname
    xdotool
    xsel
    sutils
    #xorg.xset
    #xorg.xsetroot
    xtitle
    xclip
    sxhkd
    slock
    #lemonbar-xft
    #stalonetray
    polybar
    autorandr


    # Dev
    go
    gotools
    nodejs
    protobuf
    nodejs
    julia
    gcc
    gradle
    universal-ctags
    gist
    influxdb
    redis
    travis

    # Multimedia
    mpv
    spotify
    youtube-dl
    imagemagick
    sxiv
    ffmpeg

    # Random
    ansible
    gnome3.dconf
    gnome3.glib_networking
    pass
    playerctl
    firefox
    chromium
    #libreoffice
    gtk-engine-murrine
    #texlive.combined.scheme-small
    keybase
    slock
    wget
    termite
    zathura
    dunst
    maim
    slop
    redshift
    thunderbird
    rofi
    keychain
    networkmanagerapplet
    lxappearance
    xautolock
    xss-lock
    i3lock-color

    android-studio
  ];
}
