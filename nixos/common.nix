{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
  unstable = import <nixpkgs-unstable> {};
  mypkgs = import <mypkgs> {};
in
  {
    imports =
    [ ./hardware-configuration.nix
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
      siji
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
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      interactiveShellInit = ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        HISTFILE="''${ZDOTDIR:-$HOME}/.zhistory"
        source ${pkgs.fzf.out}/share/shell/key-bindings.zsh
        source ${pkgs.fzf.out}/share/shell/completion.zsh
      '';
      promptInit="";
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
    #slock.enable = true;
    #gnupg.agent.enable = true;

    chromium = {
      enable = true;
      homepageLocation = "https://duckduckgo.com/?key=${secrets.duckduckgo.key}";
      extensions = [
        "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
        "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
    "nixpkgs-unstable=/nix/var/nix/profiles/per-user/root/channels/nixpkgs"
    "mypkgs=/nix/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
  nixpkgs.overlays = [
    (self: super: with builtins;
    let
      # isNewer reports whether version of a is higher, than b
      isNewer = { a, b }: compareVersions a.version b.version == 1;

      # newest returns derivation with same name as pkg from super
      # if it's version is higher than version on pkg. pkg otherwise.
      newest = pkg:
      let
        name = (parseDrvName pkg.name).name;
        inSuper = if hasAttr name super then getAttr name super else null;
      in
      if (inSuper != null) && (isNewer { a = inSuper; b = pkg;} )
      then inSuper
      else pkg;
    in
    {
      go = unstable.go;
      neovim = newest mypkgs.neovim;
      mopidy-iris = newest mypkgs.mopidy-iris;
      mopidy-local-sqlite = newest mypkgs.mopidy-local-sqlite;
      mopidy-local-images = newest mypkgs.mopidy-local-images;
      mopidy-mpris = newest mypkgs.mopidy-mpris;
      ripgrep = unstable.ripgrep;
    })
  ];

  environment = {
    systemPackages = with pkgs; [
      linuxPackages.acpi_call

      microcodeIntel

      # OS/Env
      tree
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
      xtitle
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
      gcc
      gnumake
      gradle
      docker_compose
      docker-gc
      git
      git-lfs
      universal-ctags
      gist
      fzf
      ripgrep
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
      texlive.combined.scheme-small
      pandoc
      keybase
      graphviz
      slock
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
      rtorrent
      rclone
      nox
      keychain
      networkmanagerapplet
      neofetch
      lxappearance
      zip
      xautolock
      xss-lock
    ];

    sessionVariables = { 
      EMAIL="rvolosatovs@riseup";
      EDITOR="nvim";
      VISUAL="nvim";
      BROWSER="chromium";
      PAGER="less";

      QT_QPA_PLATFORMTHEME="gtk2";
    };

    variables = {
      XDG_CONFIG_HOME="\${HOME}/.config";
      XDG_CACHE_HOME="\${HOME}/.local/cache";
      XDG_DATA_HOME="\${HOME}/.local/share";

      GIMP2_DIRECTORY="\${XDG_CONFIG_HOME}/gimp";
      GNUPGHOME="\${XDG_CONFIG_HOME}/gnupg";
      GTK2_RC_FILES="\${XDG_CONFIG_HOME}/gtk-2.0/gtkrc";
      INPUTRC="\${XDG_CONFIG_HOME}/readline/inputrc";
      ELINKS_CONFDIR="\${XDG_CONFIG_HOME}/elinks";

      WINEPREFIX="\${XDG_DATA_HOME}/wine";
      TERMINFO="\${XDG_DATA_HOME}/terminfo";
      TERMINFO_DIRS=[ "\${XDG_DATA_HOME}/terminfo" "/usr/share/terminfo" ];

      TMUX_TMPDIR="\${XDG_RUNTIME_DIR}/tmux";

      LESSHISTFILE="\${XDG_CACHE_HOME}/less/history";
      __GL_SHADER_DISK_CACHE_PATH="\${XDG_CACHE_HOME}/nv";
      CUDA_CACHE_PATH="\${XDG_CACHE_HOME}/nv";
      PYTHON_EGG_CACHE="\${XDG_CACHE_HOME}/python-eggs";

      ZDOTDIR="\${XDG_CONFIG_HOME}/zsh";
      ZPLUG_HOME="\${ZDOTDIR}/zplug";

      PASSWORD_STORE_DIR="\${HOME}/.local/pass";

      GOPATH="\${HOME}";
      GOBIN="\${HOME}/.local/bin.go";
      PATH=[ "\${HOME}/.local/bin" "\${GOBIN}" "\${HOME}/.gem/ruby/2.4.0/bin" ];

      PANEL_FIFO="/tmp/panel-fifo";
      PANEL_HEIGHT="24";
      PANEL_FONT="-*-fixed-*-*-*-*-10-*-*-*-*-*-*-*";
      PANEL_WM_NAME="bspwm_panel";
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

      #    xautolock = {
        #      enable = true;
        #      locker = "${pkgs.slock}/bin/slock";
        #    };

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
            eval `${pkgs.keychain}/bin/keychain --eval id_rsa ttn`
            eval `${pkgs.keychain}/bin/keychain --eval --agents gpg`

            # Set GTK_PATH so that GTK+ can find the theme engines.
            export GTK_PATH="${config.system.path}/lib/gtk-2.0:${config.system.path}/lib/gtk-3.0"

            # Java
            export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.aatext=true -Dsun.java2d.xrender=true'

            ${config.hardware.pulseaudio.package}/bin/pactl upload-sample /usr/share/sounds/freedesktop/stereo/bell.oga x11-bell
            ${config.hardware.pulseaudio.package}/bin/pactl load-module module-x11-bell sample=x11-bell display=$DISPLAY

            ${pkgs.feh}/bin/feh  --bg-fill "$HOME/pictures/wp" 
            #${pkgs.stalonetray}/bin/stalonetray -c "''${XDG_CONFIG_HOME}/stalonetray/stalonetrayrc" &
            ${pkgs.dunst}/bin/dunst &
            ${pkgs.networkmanagerapplet}/bin/nm-applet &
            ${pkgs.xorg.xset}/bin/xset s off -dpms
            ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
            ${pkgs.wmname}/bin/wmname LG3D

            ${pkgs.sudo}/bin/sudo "''${HOME}/.local/bin/fix-keycodes"

            turbo get && turbo disable

            # Screen Locking (time-based & on suspend)
            ${pkgs.xautolock}/bin/xautolock -detectsleep -time 5 \
            -locker "/home/rvolosatovs/.local/bin/lock -s -p" \
            -notify 10 -notifier "${pkgs.libnotify}/bin/notify-send -u critical -t 10000 -- 'Screen will be locked in 10 seconds'" &
            ${pkgs.xss-lock}/bin/xss-lock -- /home/rvolosatovs/.local/bin/lock -s -p &
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
        SystemMaxUse=1G
        MaxRetentionSec=5day
      '';
      logind.extraConfig = ''
        IdleAction=suspend
        IdleActionSec=300
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
      udev.extraRules= ''
        KERNEL="ttyUSB[0-9]*", TAG+="udev-acl", TAG+="uaccess", OWNER="rvolosatovs"
        KERNEL="ttyACM[0-9]*", TAG+="udev-acl", TAG+="uaccess", OWNER="rvolosatovs"

        SUBSYSTEM!="usb_device", ACTION!="add", GOTO="avrisp_end"

        # Atmel Corp. JTAG ICE mkII
        ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2103", MODE="660", GROUP="dialout"
        # Atmel Corp. AVRISP mkII
        ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2104", MODE="660", GROUP="dialout"
        # Atmel Corp. Dragon
        ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2107", MODE="660", GROUP="dialout"

        LABEL="avrisp_end"
      '';
      mopidy = {
        enable = true;
        configuration = ''
          [local]
          enabled = false
          [soundcloud]
          auth_token = ${secrets.soundcloud.token}
          explore_songs = 25
          [spotify]
          username = ${secrets.spotify.username}
          password = ${secrets.spotify.password}
          #client_id = ${secrets.spotify.clientID}
          #client_secret = ${secrets.spotify.clientSecret}
          bitrate = 320
          timeout = 30
          [spotify/tunigo]
          enabled = true
          [youtube]
          enabled = true
        '';
        extensionPackages = with pkgs; [
          mopidy-soundcloud
          mopidy-iris
          mopidy-local-images
          mopidy-local-sqlite
          mopidy-mpris
          mopidy-spotify
          mopidy-spotify-tunigo
          mopidy-youtube
        ];
      };
    };
    virtualisation.docker.enable = true;

    systemd.services = {
      systemd-networkd-wait-online.enable = false;

      audio-off = {
        enable = true;
        description = "Mute audio before suspend";
        wantedBy = [ "sleep.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "rvolosatovs";
          ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
          RemainAfterExit = true;
        };
      };

      godoc = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        environment = {
          "GOPATH" = "/home/rvolosatovs";
        };
        serviceConfig = {
          User = "rvolosatovs";
          ExecStart = "/home/rvolosatovs/.local/bin.go/godoc -http=:6060";
        };
      };
    };

    users.users = { 
      rvolosatovs = {
        isNormalUser = true;
        initialPassword = "rvolosatovs";
        home="/home/rvolosatovs";
        description="Roman Volosatovs";
        createHome=true;
        extraGroups= [ "wheel" "input" "audio" "video" "networkmanager" "docker" "dialout" "tty" "uucp" "disk" "adm" "wireshark" ];
        shell = pkgs.zsh;
      };

      peyvand = {
        isNormalUser = true;
        initialPassword = "peyvand";
        extraGroups= [ "input" "audio" "video" ];
        shell = pkgs.zsh;
      };
    };

    system = {
      stateVersion = "17.03";
      autoUpgrade.enable = true;
    };
  }
