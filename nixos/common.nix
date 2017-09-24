{ config, pkgs, lib, ... }:

with lib;

let
  keys = import ./keys.nix;
  secrets = import ./secrets.nix;
  unstable = import <nixpkgs-unstable> {};
  mypkgs = import <mypkgs> {};

  #hosts = import ./ho

  #variables = import ./variables.nix;
  username = "rvolosatovs";
  hostname = "neon";
  dnsServer = "52.174.55.168"; # OpenNIC ns5.nh.nl
  vpnIP = "10.0.0.2" ;
in
  rec {
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

    opengl.enable = true;
    opengl.driSupport32Bit = true;

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
    #"/mnt/torrent" = {
      #  device = "${pkgs.rclone}/bin/rclonefs#gspot:/var/torrent";
      #  fsType = "fuse";
      #  options = [ "config=/home/rvolosatovs/.config/rclone/rclone.conf" "allow-other" "default-permissions" "read-only" "max-read-ahead=16M" ];
      #  noCheck = true;
      #  };
    };

    networking = {
      hostName = "${hostname}";
      networkmanager.enable = true;
      #nameservers = [
        #""
        #];
        #wireguard.interfaces = {
          #wg0  = {
            #postSetup = [ "${pkgs.bash}/bin/bash -c 'printf \"nameserver ${dnsServer}\" | ${pkgs.openresolv}/bin/resolvconf -a tun.wlp4s0 -m 0 -x'" ];
            #postShutdown = [ "${pkgs.bash}/bin/bash -c '${pkgs.openresolv}/bin/resolvconf -d tun.wlp4s0'" ];

            #ips = [ "${vpnIP}/24" ];
            #privateKey = "${secrets.wireguard.client.privateKey}";
            ## TODO
            ##privateKeyFile = "/home/${username}/.config/wireguard/privatekey";
            #peers = [
              #{
                #allowedIPs = [ "0.0.0.0/0" "::/0" ];
                #endpoint = "${secrets.servers.vpn.addr}:51820";
                #publicKey = "${secrets.wireguard.server.publicKey}";
                #presharedKey = "${secrets.wireguard.presharedKey}";
                #}
                #];
                #};
                #};
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
                    bindkey -v
                    HISTFILE="''${ZDOTDIR:-$HOME}/.zhistory"
                    if [ -n "''${commands[fzf-share]}" ]; then
                    source "`fzf-share`/completion.zsh"
                    source "`fzf-share`/key-bindings.zsh"
                    fi
                  '';
                  promptInit="";
                };
                bash.enableCompletion = true;

                ssh = {
                  askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
                  #startAgent = true;
                };

                adb.enable = true;
                light.enable = true;
                java.enable = true;
                wireshark.enable = true;
                #slock.enable = true;
                gnupg.agent = {
                  enable = true;
                  enableSSHSupport = true;
                };

                browserpass.enable = true;
                command-not-found.enable = true;
                mosh.enable = true;

                chromium = {
                  enable = true;
                  homepageLocation = "https://duckduckgo.com/?key=${secrets.duckduckgo.key}";
                  extensions = [
                    "gcbommkclmclpchllfjekcdonpmejbdp" # https everywhere
                    "klbibkeccnjlkjkiokjodocebajanakg" # great suspender
                    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock origin
                    "jegbgfamcgeocbfeebacnkociplhmfbk" # browserpass
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
                  #browserpass = newest mypkgs.browserpass;
                  #go = unstable.go;
                  mopidy-iris = newest mypkgs.mopidy-iris;
                  #mopidy-local-sqlite = newest mypkgs.mopidy-local-sqlite;
                  #mopidy-local-images = newest mypkgs.mopidy-local-images;
                  #mopidy-mpris = newest mypkgs.mopidy-mpris;
                  #neovim = newest mypkgs.neovim;
                  #keybase = newest mypkgs.keybase;
                  #ripgrep = unstable.ripgrep;
                  rclone = mypkgs.rclone;
                  smlnj = mypkgs.smlnj;
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
                  travis

                  # Multimedia
                  mpv
                  spotify
                  youtube-dl
                  imagemagick
                  sxiv
                  ffmpeg

                  #smlnj # FIXME TUE

                  dnscrypt-proxy

                  # Random
                  ansible
                  pv
                  unzip
                  gnome3.dconf
                  gnome3.glib_networking
                  wireguard
                  pass
                  playerctl
                  firefox
                  chromium
                  libreoffice
                  gtk-engine-murrine
                  #texlive.combined.scheme-small
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
                  EMAIL="${username}@riseup";
                  EDITOR="nvim";
                  VISUAL="nvim";
                  BROWSER="chromium";
                  PAGER="less";

                  QT_QPA_PLATFORMTHEME="gtk2";

                  TERMINFO="/var/run/current-system/sw/share/terminfo";
                };

                variables = {
                  XDG_CONFIG_HOME="\${HOME}/.config";
                  XDG_CACHE_HOME="\${HOME}/.local/cache";
                  XDG_DATA_HOME="\${HOME}/.local/share";

                  PASSWORD_STORE_DIR="\${HOME}/.local/pass";

                  GOPATH="\${HOME}";
                  GOBIN="\${HOME}/.local/bin.go";
                  PATH=[ "\${HOME}/.local/bin" "\${GOBIN}" "\${HOME}/.gem/ruby/2.4.0/bin" ];
                };

                # These variables should be set after some of the environment.variables
                extraInit = ''
                  export WINEPREFIX="''${XDG_DATA_HOME}/wine"

                  export TMUX_TMPDIR="''${XDG_RUNTIME_DIR}/tmux"

                  export LESSHISTFILE="''${XDG_CACHE_HOME}/less/history"
                  export __GL_SHADER_DISK_CACHE_PATH="''${XDG_CACHE_HOME}/nv"
                  export CUDA_CACHE_PATH="''${XDG_CACHE_HOME}/nv"
                  export PYTHON_EGG_CACHE="''${XDG_CACHE_HOME}/python-eggs"

                  export GIMP2_DIRECTORY="''${XDG_CONFIG_HOME}/gimp"
                  export GNUPGHOME="''${XDG_CONFIG_HOME}/gnupg"
                  export GTK2_RC_FILES="''${XDG_CONFIG_HOME}/gtk-2.0/gtkrc"
                  export INPUTRC="''${XDG_CONFIG_HOME}/readline/inputrc"
                  export ELINKS_CONFDIR="''${XDG_CONFIG_HOME}/elinks"
                  export ZDOTDIR="''${XDG_CONFIG_HOME}/zsh"

                  export ZPLUG_HOME="''${ZDOTDIR}/zplug";
                '';

                shells = [ 
                  /var/run/current-system/sw/bin/zsh
                ];
              };

              security = {
                sudo = {
                  enable = true;
                  wheelNeedsPassword = false;
                };
              };

              services = {
                gnome3 = {
                  gnome-keyring.enable = true;
                  seahorse.enable = true;
                };
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
                    user = "${username}";
                    };
                    greeters.gtk = {
                    theme.package = pkgs.zuki-themes;
                    theme.name = "Zukitre";
                    };
                    };
                    sessionCommands = ''
                    #eval `${pkgs.keychain}/bin/keychain --eval id_rsa ttn`
                    #eval `${pkgs.keychain}/bin/keychain --eval --agents gpg`
                    #eval `${pkgs.keychain}/bin/keychain --eval --agents ssh`

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

                      ${pkgs.sudo}/bin/sudo ''${HOME}/.local/bin/fix-keycodes

                      ''${HOME}/.local/bin/turbo disable

                      # Screen Locking (time-based & on suspend)
                      ${pkgs.xautolock}/bin/xautolock -detectsleep -time 5 \
                      -locker "/home/${username}/.local/bin/lock -s -p" \
                      -notify 10 -notifier "${pkgs.libnotify}/bin/notify-send -u critical -t 10000 -- 'Screen will be locked in 10 seconds'" &
                      ${pkgs.xss-lock}/bin/xss-lock -- /home/${username}/.local/bin/lock -s -p &
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
                openvpn = {
                  servers = {
                    my = {
                      config = ''
                        client
                        dev tun
                        proto udp
                        sndbuf 0
                        rcvbuf 0
                        remote ${secrets.servers.vpn.addr}
                        resolv-retry infinite
                        nobind
                        persist-key
                        persist-tun
                        remote-cert-tls server
                        auth SHA512
                        cipher AES-256-CBC
                        comp-lzo
                        setenv opt block-outside-dns
                        key-direction 1
                        verb 3
                        ca /home/${username}/.config/vpn/ca.crt
                        tls-auth /home/${username}/.config/vpn/tls.key
                        cert /home/${username}/.config/vpn/${hostname}.crt
                        key /home/${username}/.config/vpn/${hostname}.key
                      '';
                      #up = "echo nameserver $nameserver | ${pkgs.openresolv}/sbin/resolvconf -m 0 -a $dev";
                      #down = "${pkgs.openresolv}/sbin/resolvconf -d $dev";
                    };
                  };
                };
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
                    # No errors occured so far, so maybe it's not required...
                    ## For BTRFS
                    ## https://wiki.archlinux.org/index.php/TLP#Btrfs
                    #SATA_LINKPWR_ON_BAT=max_performance

                    # Battery health
                    START_CHARGE_THRESH_BAT0=75
                    STOP_CHARGE_THRESH_BAT0=90
                    START_CHARGE_THRESH_BAT1=75
                    STOP_CHARGE_THRESH_BAT1=90
                  '';
                };
                dnscrypt-proxy = {
                  enable = true;
                };
                #unbound = {
                  #enable = true;
                  #extraConfig = ''
                   #server:
                    #do-not-query-localhost: no
                    #forward-zone:
                      #name: "."
                      #forward-addr: 127.0.0.1@5353
                  #'';
                #};
                #udev.extraRules= ''
                #KERNEL="ttyUSB[0-9]*", TAG+="udev-acl", TAG+="uaccess", OWNER="rvolosatovs"
                #KERNEL="ttyACM[0-9]*", TAG+="udev-acl", TAG+="uaccess", OWNER="rvolosatovs"

                #SUBSYSTEM!="usb_device", ACTION!="add", GOTO="avrisp_end"

                ## Atmel Corp. JTAG ICE mkII
                #ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2103", MODE="660", GROUP="dialout"
                ## Atmel Corp. AVRISP mkII
                #ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2104", MODE="660", GROUP="dialout"
                ## Atmel Corp. Dragon
                #ATTR{idVendor}=="03eb", ATTRS{idProduct}=="2107", MODE="660", GROUP="dialout"

                #LABEL="avrisp_end"
                #'';
              };

              virtualisation = {
                docker.enable = true;
                virtualbox.host.enable = true;
              };

              systemd = {
                #mounts = [
                  #{
                    #enable = true;
                    #wantedBy = [ "multi-user.target" ];
                    #after = [ "network-online.target" ];
                    #wants = [ "network-online.target" ];
                    ##requires = [ "systemd-networkd.service" ];
                    #what = "${pkgs.rclone}/bin/rclonefs#${secrets.servers.torrent.hostname}:/var/torrent";
                    #where = "/mnt/torrent";
                    #type = "fuse";
                    #options="auto,config=/home/${username}/.config/rclone/rclone.conf,allow-other,default-permissions,read-only,max-read-ahead=16M";
                    #mountConfig = {
                      #Environment = "SSH_AUTH_SOCK=/var/run/user/1000/gnupg/d.688bdxm4zjigcn1ip7rw474j/S.gpg-agent.ssh";
                      #TimeoutSec = "10";
                      #};
                      #}
                      #];

                      services = {
                        systemd-networkd-wait-online.enable = false;

                        audio-off = {
                          enable = true;
                          description = "Mute audio before suspend";
                          wantedBy = [ "sleep.target" ];
                          serviceConfig = {
                            Type = "oneshot";
                            User = "${username}";
                            ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
                            RemainAfterExit = true;
                          };
                        };

                        godoc = {
                          enable = true;
                          wantedBy = [ "multi-user.target" ];
                          environment = {
                            "GOPATH" = "/home/${username}";
                          };
                          serviceConfig = {
                            User = "${username}";
                            ExecStart = "${pkgs.gotools}/bin/godoc -http=:6060";
                          };
                        };

                        openvpn-reconnect = {
                          enable = true;
                          description = "Restart OpenVPN after suspend";

                          wantedBy= [ "sleep.target" ];
                          
                          serviceConfig = {
                            ExecStart="${pkgs.procps}/bin/pkill --signal SIGHUP --exact openvpn";
                          };
                        };
                      };
                      #user.services = {
                        #torrents = {
                          #wantedBy = [ "default.target" ];
                          #after = [ "ssh-agent.service" "gpg-agent-ssh.socket" ];
                          #wants = [ "ssh-agent.service" "gpg-agent-ssh.socket" ];
                          #environment = {
                            #"SSH_AUTH_SOCK" = "%t/gnupg/d.688bdxm4zjigcn1ip7rw474j/S.gpg-agent.ssh";
                            #"PATH" = "/var/run/current-system/bin";
                            #};
                            #serviceConfig = {
                              #ExecStart = "${pkgs.rclone}/bin/rclone mount ${secrets.servers.torrent.hostname}:/var/torrent %h/mnt/torrent";
                              #};
                              #};
                              #};
                            };


                            users = {
                              defaultUserShell = pkgs.zsh;
                              users = { 
                                rvolosatovs = {
                                  isNormalUser = true;
                                  initialPassword = "${username}";
                                  home="/home/${username}";
                                  description="Roman Volosatovs";
                                  createHome=true;
                                  extraGroups= [ "wheel" "input" "audio" "video" "networkmanager" "docker" "dialout" "tty" "uucp" "disk" "adm" "wireshark" ];
                                  openssh.authorizedKeys = {
                                    keys = [
                                      keys.publicKey
                                    ];
                                  };
                                };

                                peyvand = {
                                  isNormalUser = true;
                                  initialPassword = "peyvand";
                                  extraGroups= [ "input" "audio" "video" ];
                                };
                              };
                            };

                            system = {
                              stateVersion = "17.03";
                              autoUpgrade.enable = true;
                            };
                          }
