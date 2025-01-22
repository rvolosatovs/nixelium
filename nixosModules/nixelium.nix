{
  self,
  home-manager,
  lanzaboote,
  nixlib,
  nixpkgs-legacy,
  nixpkgs-nixos,
  sops-nix,
  wit-deps,
  ...
}: {
  config,
  pkgs,
  ...
}:
with nixlib.lib; let
  cfg = config.nixelium;

  email = "rvolosatovs@riseup.net";
  username = "rvolosatovs";

  nopasswd = command: {
    inherit command;
    options = ["NOPASSWD" "SETENV"];
  };

  butterSubvol = subvol: {
    device = "/dev/disk/by-label/butter";
    fsType = "btrfs";
    options = [
      "autodefrag"
      "compress=zstd"
      "noatime"
      "ssd"
      "subvol=${subvol}"
    ];
  };

  # deploySystemPath is the path where the system being activated is uploaded by `deploy`.
  deploySystemPath = "/nix/store/*-activatable-nixos-system-${config.networking.hostName}-*";
in {
  imports = [
    home-manager.nixosModules.home-manager
    lanzaboote.nixosModules.lanzaboote
    sops-nix.nixosModules.sops
  ];

  options.nixelium.build.enable = mkEnableOption "`nix` remote build setup";
  options.nixelium.deploy.enable = mkEnableOption "`deploy-rs` setup";
  options.nixelium.profile.laptop.enable = mkEnableOption "laptop profile";
  options.nixelium.system.isVirtual = mkEnableOption "system virtualization";

  config = mkMerge [
    {
      boot.bootspec.enable = true;
      boot.initrd.availableKernelModules = [
        "cryptd"
      ];
      boot.initrd.systemd.enable = true;
      boot.kernelParams = [
        "systemd.unified_cgroup_hierarchy=1"
      ];
      boot.lanzaboote.enable = mkDefault true;
      boot.lanzaboote.pkiBundle = "/etc/secureboot";
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.grub.enable = false;
      boot.loader.systemd-boot.enable = !config.boot.lanzaboote.enable;
      boot.tmp.cleanOnBoot = true;

      environment.homeBinInPath = true;
      environment.localBinInPath = true;
      environment.pathsToLink = [
        "/share/bash"
        "/share/bash-completion"
        "/share/zsh"
      ];

      fonts.fontconfig.allowBitmaps = true;
      fonts.fontconfig.allowType1 = false;
      fonts.fontconfig.antialias = true;
      fonts.fontconfig.defaultFonts.monospace = ["Fira Code" "FiraCode Nerd Font"];
      fonts.fontconfig.defaultFonts.sansSerif = ["Fira Sans"];
      fonts.fontconfig.defaultFonts.serif = ["Roboto Slab"];
      fonts.fontconfig.hinting.enable = true;

      hardware.bluetooth.settings.General.ControllerMode = "dual";
      hardware.bluetooth.powerOnBoot = true;

      hardware.trackpoint.sensitivity = 250;
      hardware.trackpoint.speed = 120;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.owner = self.homeModules.default;
      home-manager.users.root = self.homeModules.default;

      hardware.enableRedistributableFirmware = true;

      networking.domain = mkDefault "ghost-ordinal.ts.net";
      networking.firewall.checkReversePath = "loose";
      networking.firewall.enable = true;
      networking.nameservers = [
        "2620:fe::fe"
        "2620:fe::9"
        "9.9.9.9"
        "149.112.112.112"
      ];
      networking.stevenblack.enable = true;
      networking.useDHCP = true;
      networking.useNetworkd = true;

      nix.gc.automatic = true;
      nix.optimise.automatic = true;
      nix.settings.allowed-users = with config.users; [
        "@${groups.wheel.name}"
        users.owner.name
        users.root.name
      ];
      nix.settings.require-sigs = true;
      nix.settings.substituters = [
        "https://rvolosatovs.cachix.org"
        "https://nixify.cachix.org"
        "https://cache.nixos.org"
        "https://wasmcloud.cachix.org"
        "https://crane.cachix.org"
        "https://nix-community.cachix.org"
      ];
      nix.settings.trusted-public-keys = [
        "rvolosatovs.cachix.org-1:eRYUO4OXTSmpDFWu4wX3/X08MsP01baqGKi9GsoAmQ8="
        "nixify.cachix.org-1:95SiUQuf8Ij0hwDweALJsLtnMyv/otZamWNRp1Q1pXw="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "wasmcloud.cachix.org-1:9gRBzsKh+x2HbVVspreFg/6iFRiD4aOcUQfXVDl3hiM="
        "crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      nix.settings.trusted-users = with config.users; [
        "@${groups.wheel.name}"
        users.owner.name
        users.root.name
      ];
      nix.extraOptions = concatStringsSep "\n" [
        "keep-outputs = true"
        "keep-derivations = true"
        "experimental-features = nix-command flakes"
      ];

      nixpkgs.config = import "${self}/nixpkgs/config.nix";
      nixpkgs.overlays = [
        self.overlays.default

        wit-deps.overlays.default
      ];

      programs.zsh.autosuggestions.enable = true;
      programs.zsh.autosuggestions.strategy = ["history" "completion"];
      programs.zsh.enable = true;
      programs.zsh.enableBashCompletion = true;
      programs.zsh.enableGlobalCompInit = false;
      programs.zsh.histFile = "$HOME/.config/zsh/.zsh_history";
      programs.zsh.histSize = 50000;
      programs.zsh.setOptions = ["INTERACTIVE_COMMENTS" "NO_NOMATCH"];
      programs.zsh.syntaxHighlighting.enable = true;

      security.acme.acceptTerms = true;
      security.acme.defaults.email = email;

      security.sudo.enable = true;
      security.sudo.extraRules = [
        {
          groups = with config.users.groups; [wheel.name];
          runAs = config.users.users.root.name;
          commands = [
            (nopasswd "ALL")
          ];
        }
      ];
      security.sudo.wheelNeedsPassword = false;

      services.journald.extraConfig = ''
        SystemMaxUse=1G
        MaxRetentionSec=5day
      '';

      services.nginx.recommendedGzipSettings = true;
      services.nginx.recommendedOptimisation = true;
      services.nginx.recommendedProxySettings = true;
      services.nginx.recommendedTlsSettings = true;
      services.nginx.sslProtocols = "TLSv1.3";
      services.nginx.sslCiphers = concatStringsSep ":" [
        "ECDHE-ECDSA-AES256-GCM-SHA384"
        "ECDHE-ECDSA-AES128-GCM-SHA256"
        "ECDHE-ECDSA-CHACHA20-POLY1305"
      ];
      services.nginx.appendHttpConfig = ''
        proxy_ssl_protocols TLSv1.3;
      '';

      services.openssh.enable = true;
      services.openssh.hostKeys = [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
          rounds = 100;
        }
      ];
      services.openssh.settings.PasswordAuthentication = false;
      services.openssh.settings.PermitRootLogin = mkDefault "no";
      services.openssh.settings.X11Forwarding = true;
      services.openssh.startWhenNeeded = true;

      services.printing.drivers = with pkgs; [
        brlaser
      ];

      services.tailscale.enable = true;

      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      system.stateVersion = "24.11";

      systemd.network.wait-online.anyInterface = true;
      systemd.network.wait-online.ignoredInterfaces = [
        "lo"
        "tailscale0"
      ];

      time.timeZone = mkDefault "Europe/Zurich";

      users.defaultUserShell = pkgs.zsh;

      users.users.root.hashedPassword = "!";

      users.users.owner.extraGroups = [
        config.security.tpm2.tssGroup

        config.users.groups.adm.name
        config.users.groups.audio.name
        config.users.groups.cdrom.name
        config.users.groups.dialout.name
        config.users.groups.disk.name
        config.users.groups.floppy.name
        config.users.groups.input.name
        config.users.groups.kmem.name
        config.users.groups.kvm.name
        config.users.groups.lp.name
        config.users.groups.render.name
        config.users.groups.sgx.name
        config.users.groups.tape.name
        config.users.groups.tty.name
        config.users.groups.utmp.name
        config.users.groups.uucp.name
        config.users.groups.video.name
        config.users.groups.wheel.name
      ];
      users.users.owner.isNormalUser = true;
      users.users.owner.initialHashedPassword = "";
      users.users.owner.name = username;
      users.users.owner.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKEC3hGlw5tDKcfbvTd+IdZxGSdux1i/AIK3mzx4bZuX"
      ];
      users.users.owner.shell = pkgs.zsh;

      virtualisation.oci-containers.backend = "podman";
      virtualisation.podman.dockerCompat = mkDefault true;
      virtualisation.podman.dockerSocket.enable = mkDefault true;
      virtualisation.podman.enable = true;
    }

    (mkIf cfg.build.enable {
      nix.settings.allowed-users = with config.users; [
        "${users.nix.name}"
      ];
      nix.settings.trusted-users = with config.users; [
        "${users.nix.name}"
      ];

      users.groups.nix = {};

      users.users.nix.group = config.users.groups.nix.name;
      users.users.nix.isSystemUser = true;
      users.users.nix.openssh.authorizedKeys.keys =
        config.users.users.owner.openssh.authorizedKeys.keys
        ++ [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHYL7ukR5D6oNAmYo/CeyLAMGAYV6SxfZJAOcx/KIZTG" # cobalt root
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArsbOOVUDNepUwdFmY0h/XFMrLJ5C55NNP+xC8WKVoi" # iridium root
        ];
      users.users.nix.shell = pkgs.bashInteractive;
    })

    (mkIf cfg.deploy.enable {
      environment.shells = with pkgs; [
        bashInteractive
      ];

      nix.settings.allowed-users = with config.users; [
        "@${groups.deploy.name}"
      ];
      nix.settings.trusted-users = with config.users; [
        "@${groups.deploy.name}"
      ];

      security.sudo.extraRules = [
        {
          groups = with config.users.groups; [deploy.name];
          runAs = config.users.users.root.name;
          commands = [
            (nopasswd "${deploySystemPath}/activate-rs activate *")
            (nopasswd "${deploySystemPath}/activate-rs wait *")
            (nopasswd "/run/current-system/sw/bin/rm /tmp/deploy-rs*")
          ];
        }
        {
          groups = with config.users.groups; [ops.name];
          runAs = config.users.users.root.name;
          commands = [
            (nopasswd "/run/current-system/sw/bin/systemctl reboot")
            (nopasswd "/run/current-system/sw/bin/systemctl restart *")
            (nopasswd "/run/current-system/sw/bin/systemctl start *")
            (nopasswd "/run/current-system/sw/bin/systemctl stop *")
          ];
        }
      ];

      users.groups.deploy = {};
      users.groups.ops = {};

      users.users.deploy.group = config.users.groups.deploy.name;
      users.users.deploy.isSystemUser = true;
      users.users.deploy.openssh.authorizedKeys.keys = config.users.users.owner.openssh.authorizedKeys.keys;
      users.users.deploy.shell = pkgs.bashInteractive;

      users.users.owner.extraGroups = with config.users.groups; [
        ops.name
        deploy.name
      ];
    })

    (mkIf cfg.profile.laptop.enable {
      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "wasm32-wasi"
      ];

      boot.initrd.luks.devices.luksroot.allowDiscards = true;

      boot.kernelPackages = pkgs.pkgsUnstable.linuxPackages_zen;

      fileSystems."/" = butterSubvol "@";
      fileSystems."/.snapshots" = butterSubvol "@-snapshots";
      fileSystems."/home" = butterSubvol "@home";
      fileSystems."/home/.snapshots" = butterSubvol "@home-snapshots";

      fileSystems."/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };

      fonts.enableDefaultPackages = true;
      fonts.fontconfig.enable = true;
      fonts.fontDir.enable = true;
      fonts.packages = [
        pkgs.fira
        pkgs.fira-code
        pkgs.fira-code-nerdfont
        pkgs.fira-code-symbols
        pkgs.fira-mono
        pkgs.font-awesome
        pkgs.roboto-slab
      ];

      hardware.bluetooth.package = nixpkgs-legacy.legacyPackages.${pkgs.stdenv.hostPlatform.system}.bluez; # downgrade to fix controllers https://github.com/bluez/bluez/issues/605

      hardware.graphics.enable32Bit = true;
      hardware.graphics.enable = true;

      hardware.steam-hardware.enable = true;

      location.latitude = mkDefault 46.3;
      location.longitude = mkDefault 7.5;

      programs.adb.enable = true;

      programs.dconf.enable = true;

      programs.gamescope.capSysNice = true;
      programs.gamescope.enable = true;

      programs.light.enable = true;

      programs.steam.enable = true;
      programs.steam.gamescopeSession.enable = true;
      programs.steam.remotePlay.openFirewall = true;

      qt.enable = true;
      qt.platformTheme = "qt5ct";
      #qt.style = "adwaita-dark";

      security.pam.loginLimits = [
        {
          domain = "@users";
          item = "rtprio";
          type = "-";
          value = 1;
        }
      ];
      security.pam.services.swaylock = {};

      security.polkit.enable = true;

      security.tpm2.enable = true;
      security.tpm2.pkcs11.enable = true;
      security.tpm2.tctiEnvironment.enable = true;

      security.rtkit.enable = true;

      security.unprivilegedUsernsClone = true;

      services.avahi.enable = true;

      services.btrfs.autoScrub.enable = true;
      services.btrfs.autoScrub.fileSystems = [
        "/"
      ];

      services.dbus.enable = true;

      services.fstrim.enable = true;

      services.fwupd.enable = true;

      services.mullvad-vpn.enable = true;
      services.mullvad-vpn.package = pkgs.pkgsUnstable.mullvad-vpn;

      services.pcscd.enable = true;

      services.pipewire.enable = true;
      services.pipewire.alsa.enable = true;
      services.pipewire.alsa.support32Bit = true;
      services.pipewire.pulse.enable = true;

      services.printing.enable = true;

      services.snapper.configs.home.ALLOW_USERS = [config.users.users.owner.name];
      services.snapper.configs.home.FREE_LIMIT = "0.3";
      services.snapper.configs.home.SPACE_LIMIT = "0.2";
      services.snapper.configs.home.SUBVOLUME = "/home";
      services.snapper.configs.home.TIMELINE_CLEANUP = true;
      services.snapper.configs.home.TIMELINE_CREATE = true;

      services.snapper.configs.root.ALLOW_USERS = [config.users.users.owner.name];
      services.snapper.configs.root.FREE_LIMIT = "0.4";
      services.snapper.configs.root.SPACE_LIMIT = "0.1";
      services.snapper.configs.root.SUBVOLUME = "/";
      services.snapper.configs.root.TIMELINE_CLEANUP = true;
      services.snapper.configs.root.TIMELINE_CREATE = true;

      services.snapper.snapshotRootOnBoot = true;

      services.udev.packages = with pkgs; [
        android-udev-rules
        libu2f-host
        openocd
        yubikey-manager
        yubikey-personalization
      ];
      services.udev.extraRules = with config.users.users; ''
        # General
        KERNEL=="ttyACM*", OWNER="${owner.name}"
        KERNEL=="ttyUSB*", OWNER="${owner.name}"

        # OLKB kerboards
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="feed", OWNER="${owner.name}"

        # Planck Rev6 bootloader
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", OWNER="${owner.name}"

        # Keyboardio
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2301", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", OWNER="${owner.name}"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", OWNER="${owner.name}"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300", ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0", OWNER="${owner.name}"
        SUBSYSTEM=="tty", ATTRS{idVenor}=="1209", ATTRS{idProduct}=="230[0-3]", OWNER="${owner.name}"

        # Atmel ATMega32U4
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", OWNER="${owner.name}"

        # Atmel USBKEY AT90USB1287
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffb", OWNER="${owner.name}"

        # Atmel ATMega32U2
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff0", OWNER="${owner.name}"

        # SparkFun Pro Micro
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="920[34567]", ENV{ID_MM_DEVICE_IGNORE}="1", OWNER="${owner.name}"

        # Teensy
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", OWNER="${owner.name}"
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
        ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"

        #
        # Debuggers
        #

        # Black Magic Probe
        SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic GDB Server"
        SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic UART Port"
      '';

      services.libinput.enable = true;
      services.libinput.touchpad.middleEmulation = false;
      services.libinput.touchpad.scrollButton = 1;

      swapDevices = [{device = "/dev/disk/by-label/swap";}];

      systemd.defaultUnit = "graphical.target";

      systemd.services.swap-backspace.description = "Swap backspace and \\";
      systemd.services.swap-backspace.enable = true;
      systemd.services.swap-backspace.script = ''
        ${pkgs.kbd}/bin/setkeycodes 0e 43
        ${pkgs.kbd}/bin/setkeycodes 2b 14
      '';
      systemd.services.swap-backspace.serviceConfig.RemainAfterExit = true;
      systemd.services.swap-backspace.serviceConfig.Type = "oneshot";
      systemd.services.swap-backspace.wantedBy = ["multi-user.target"];

      users.users.owner.extraGroups = with config.users.groups; [
        adbusers.name
      ];

      xdg.portal.config.common.default = "*";
      xdg.portal.enable = true;
      xdg.portal.extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      xdg.portal.wlr.enable = true;
    })

    (mkIf (cfg.profile.laptop.enable && pkgs.stdenv.hostPlatform.isx86_64) {
      boot.binfmt.emulatedSystems = [
        "x86_64-windows"
      ];
    })

    (mkIf (cfg.profile.laptop.enable && !cfg.system.isVirtual) {
      hardware.bluetooth.enable = true;

      networking.wireless.iwd.enable = true;

      services.tlp.enable = true;

      systemd.services.audio-off.description = "Mute audio before suspend";
      systemd.services.audio-off.enable = true;
      systemd.services.audio-off.serviceConfig.ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
      systemd.services.audio-off.serviceConfig.RemainAfterExit = true;
      systemd.services.audio-off.serviceConfig.Type = "oneshot";
      systemd.services.audio-off.serviceConfig.User = config.users.users.owner.name;
      systemd.services.audio-off.wantedBy = ["sleep.target"];
    })
  ];
}
