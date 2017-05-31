# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
  ./hardware-configuration.nix
];

boot = {
  loader = {
    grub.enable = false;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  initrd.luks.devices = [
    {
      name = "luksroot";
      device = "/dev/sda2"; 
      preLVM=true; 
      allowDiscards=true;
    }
  ];
  cleanTmpDir = true;
};

hardware = {
  pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
  trackpoint.emulateWheel = true;
};

fonts = {
  enableFontDir = true;
  enableGhostscriptFonts = true;
  fonts = with pkgs; [
    terminus_font
    dejavu_fonts
    font-awesome-ttf
    fira
    fira-mono
  ];
};

fileSystems = {
  "/".options = [ "noatime" "nodiratime" "discard" ];
  "/home".options = [ "noatime" "nodiratime" "discard" ];
};

networking = {
  hostName = "neon";
  networkmanager.enable = true;
};

i18n = {
  consoleFont = "Lat2-Terminus16";
  consoleKeyMap = "us";
  defaultLocale = "en_US.UTF-8";
};

time.timeZone = "Europe/Amsterdam";

programs = {
  vim.defaultEditor = true;

  zsh = {
    enable = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        HISTFILE="''${ZDOTDIR:-$HOME}/.zhistory"
    '';
  };
  bash.enableCompletion = true;

  ssh = {
    askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
    startAgent = false;
  };

  adb.enable = true;
  light.enable = true;
  java.enable = true;
  wireshark.enable = true;
  slock.enable = true;
  gnupg.agent.enable = true;

  chromium = {
    enable = true;
    homepageLocation = "https://duckduckgo.com/?kae=t&kap=v66-2&kl=nl-nl&kad=en_US&kp=-1&kaj=m&kam=osm&kt=Fira+Sans&ka=Fira+Sans";
    extensions = [
      "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
      "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
      "fjnbnpbmkenffdnngjfgmeleoegfcffe" # stylish
    ];
  };
};

nixpkgs.config.allowUnfree = true;
environment = {
  systemPackages = with pkgs; [
    # OS/Env
    grml-zsh-config
    bc
    psmisc
    xdg-user-dirs
    htop
    pciutils
    powertop
    lsof
    whois
    acpi
    libressl
    acpi
    lm_sensors
    gnupg
    gnupg1compat
    libnotify

    # X11
    xdo
    wmname
    xdotool
    xsel
    #xorg.xset
    #xorg.xsetroot
    xclip
    sxhkd
    slock
    lemonbar-xft
    autorandr

    # Dev
    go
    nodejs
    protobuf3_2
    nodejs
    julia
    neovim
    gnumake
    gradle
    docker_compose
    docker-gc
    git
    git-lfs
    gist
    fzf
    platinum-searcher
    curl
    influxdb
    redis

    # Multimedia
    mpv
    spotify
    youtube-dl
    imagemagick
    sxiv
    ffmpeg

    # Random
    pass
    firefox
    chromium
    libreoffice
    pandoc
    keybase
    wget
    termite
    zathura
    dunst
    maim
    slop 
    redshift
    weechat
    tree
    thunderbird
    rofi
    rclone
    nox
    keychain
    networkmanagerapplet
  ];

  sessionVariables = { 
    EMAIL="rvolosatovs@riseup";
    EDITOR="nvim";
    VISUAL="nvim";
    BROWSER="chromium";
    PAGER="less";

    QT_QPA_PLATFORMTHEME="gtk2";

    XDG_CONFIG_HOME="$HOME/.config";
    XDG_CACHE_HOME="$HOME/.local/cache";
    XDG_DATA_HOME="$HOME/.local/share";

    GIMP2_DIRECTORY="$XDG_CONFIG_HOME/gimp";
    GNUPGHOME="$XDG_CONFIG_HOME/gnupg";
    GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc";
    INPUTRC="$XDG_CONFIG_HOME/readline/inputrc";
    ELINKS_CONFDIR="$XDG_CONFIG_HOME/elinks";

    WINEPREFIX="$XDG_DATA_HOME/wine";
    TERMINFO="$XDG_DATA_HOME/terminfo";
    TERMINFO_DIRS=[ "$XDG_DATA_HOME/terminfo" "/usr/share/terminfo" ];

    TMUX_TMPDIR="$XDG_RUNTIME_DIR/tmux";

    LESSHISTFILE="$XDG_CACHE_HOME/less/history";
    __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv";
    CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv";
    PYTHON_EGG_CACHE="$XDG_CACHE_HOME/python-eggs";

    ZDOTDIR="$XDG_CONFIG_HOME/zsh";
    ZPLUG_HOME="$ZDOTDIR/zplug";

    PASSWORD_STORE_DIR="$HOME/.local/pass";

    GOPATH="$HOME";
    GOBIN="$HOME/.local/bin.go";
    PATH=[ "$HOME/.local/bin" "$GOBIN" "$HOME/.gem/ruby/2.4.0/bin" ];
  };

  shells = [ 
    pkgs.zsh
  ];
};

security = {
  sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
};

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

services = {
  xserver = {
    enable = true;
    xkbModel = "thinkpad";
    xkbVariant = "qwerty";
    layout = "lv,ru";
    xkbOptions = "grp:alt_space_toggle,terminate:ctrl_alt_bksp,eurosign:5,caps:escape";
    xrandrHeads = [ "DP1" "eDP1" ];
    resolutions = [ { x = 3840; y = 2160; } { x = 1920; y = 1080; } ];
    libinput = {
      enable = true;
      scrollButton = 1;
      middleEmulation = false;
    };

    exportConfiguration = true;

    videoDrivers = [ "intel" ];

    xautolock = {
      enable = true;
      locker = "${pkgs.slock}/bin/slock";
    };

    desktopManager = {
      default = "none";
      xterm.enable = false;
    };

    displayManager = {
      lightdm = {
        enable = true;
        autoLogin = {
          enable = true;
          user = "rvolosatovs";
        };
        greeters.gtk = {
          theme.package = pkgs.zuki-themes;
          theme.name = "Zukitre";
        };
      };
      sessionCommands = ''
          eval `${pkgs.keychain}/bin/keychain --eval`

          # Set GTK_PATH so that GTK+ can find the theme engines.
          export GTK_PATH="${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0"

          # Java
          export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true'

          ${config.hardware.pulseaudio.package}/bin/pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
          ${config.hardware.pulseaudio.package}/bin/pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

          ${pkgs.feh}/bin/feh  --bg-max "$HOME/pictures/bg" 
          ${pkgs.stalonetray}/bin/stalonetray -c "$XDG_CONFIG_HOME/stalonetray/stalonetrayrc" &
          ${pkgs.dunst}/bin/dunst &
          ${pkgs.networkmanagerapplet}/bin/nm-applet &
          ${pkgs.xorg.xset}/bin/xset s off -dpms
          ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
          ${pkgs.wmname}/bin/wmname LG3D

          ${pkgs.sudo}/bin/sudo "$HOME/.local/bin/fix-keycodes"
      '';
    };
    windowManager = {
      default = "bspwm";
      bspwm.enable = true;
    };
  };
  redshift = {
    enable = true;
    latitude = "51.4";
    longitude = "5.4";
  };
  ntp.enable = true;
  upower.enable = true;
  xbanish.enable = true;
  fprintd.enable = true;
  printing.enable = true;
  thermald.enable = true;
  openssh.enable = true;
  acpid.enable = true;
  journald.extraConfig = ''
      MaxRetentionSec=5day
  '';
  tlp = {
    enable = true;
    extraConfig = ''
        START_CHARGE_THRESH_BAT0=75
        STOP_CHARGE_THRESH_BAT0=90
        START_CHARGE_THRESH_BAT1=75
        STOP_CHARGE_THRESH_BAT1=90
    '';
  };
};
virtualisation.docker.enable = true;

# Enable the X11 windowing system.
users.users = { 
  rvolosatovs = {
    isNormalUser = true;
    initialPassword = "rvolosatovs";
    home="/home/rvolosatovs";
    description="Roman Volosatovs";
    createHome=true;
    extraGroups= [ "wheel" "input" "audio" "video" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  peyvand = {
    isNormalUser = true;
    initialPassword = "peyvand";
    extraGroups= [ "input" "audio" "video" ];
    shell = pkgs.zsh;
  };
};

# The NixOS release to be compatible with for stateful data such as databases.
system = {
  stateVersion = "17.03";
  autoUpgrade.enable = true;
};
}
