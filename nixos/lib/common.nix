{ config, pkgs, lib, secrets, vars, keys, mypkgs, unstable, ... }:

let
  mountOpts = if vars.isSSD then [ "noatime" "nodiratime" "discard" ] else "TODO";
in
  {
    fileSystems = {
      "/".options = mountOpts;
      "/home".options = mountOpts;
    };

    networking.hostName = vars.hostname;
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ ];
    networking.networkmanager.enable = true;

    services.xbanish.enable = true;
    services.openssh.enable = true;
    services.printing.enable = true;
    services.ntp.enable = true;

    i18n.consoleFont = "Lat2-Terminus16";
    i18n.consoleKeyMap = "us";
    i18n.defaultLocale = "en_US.UTF-8";

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
            source "`${pkgs.fzf}/bin/fzf-share`/completion.zsh"
            source "`${pkgs.fzf}/bin/fzf-share`/key-bindings.zsh"
        '';
        promptInit="";
      };
      bash.enableCompletion = true;
      mosh.enable = true;
      command-not-found.enable = true;
    };

    nix.nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
      "nixpkgs-unstable=/nix/var/nix/profiles/per-user/root/channels/nixpkgs"
      "mypkgs=/nix/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    #nix.useSandbox = true;
    nix.autoOptimiseStore = true;
    nix.gc.automatic = true;
    nix.optimise.automatic = true;
    nix.extraOptions = ''
         gc-keep-outputs = true
    '';

    time.timeZone = "Europe/Amsterdam";

    environment.sessionVariables.EMAIL = vars.email;
    environment.sessionVariables.EDITOR = vars.editor;
    environment.sessionVariables.VISUAL = vars.editor;
    environment.sessionVariables.BROWSER = vars.browser;
    environment.sessionVariables.MAILER = vars.mailer;
    environment.sessionVariables.PAGER = vars.pager;

    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = false;

    services.journald.extraConfig = ''
        SystemMaxUse=1G
        MaxRetentionSec=5day
    '';
    services.logind.extraConfig = ''
        IdleAction=suspend
        IdleActionSec=300
    '';
    #services.dnscrypt-proxy.enable = true;

    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = true;

    users.defaultUserShell = pkgs.zsh;
    users.users."${vars.username}" = {
      isNormalUser = true;
      initialPassword = "${vars.username}";
      home="/home/${vars.username}";
      createHome=true;
      extraGroups= [ "wheel" "input" "audio" "video" "networkmanager" "docker" "dialout" "tty" "uucp" "disk" "adm" "wireshark" "mopidy" ];
      openssh.authorizedKeys.keys = [
        keys.publicKey
      ];
    };

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.overlays = [
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
        asd = asd;
        mopidy-iris = mypkgs.mopidy-iris;
        #mopidy-local-sqlite = newest mypkgs.mopidy-local-sqlite;
        #mopidy-local-images = newest mypkgs.mopidy-local-images;
        #mopidy-mpris = newest mypkgs.mopidy-mpris;
        #neovim = newest mypkgs.neovim;
        #keybase = newest mypkgs.keybase;
        #ripgrep = unstable.ripgrep;
        #rclone = mypkgs.rclone;
      })
    ];
    nixpkgs.config.neovim.vimAlias = true;

    environment.shells = [ pkgs.zsh ];
    environment.systemPackages = with pkgs; [
      bc
      curl
      docker-gc
      fzf
      git
      git-lfs
      gnumake
      gnupg
      gnupg1compat
      graphviz
      grml-zsh-config
      htop
      httpie
      jq
      lm_sensors
      lsof
      neofetch
      nix-repl
      nox
      pandoc
      pciutils
      psmisc
      pv
      rclone
      rfkill
      ripgrep
      tree
      unstable.direnv
      unstable.docker_compose
      unstable.neovim
      unzip
      weechat
      whois
      wireguard
      xdg-user-dirs
      zip
    ];

    systemd = {
      services = {
        systemd-networkd-wait-online.enable = false;

        audio-off = {
          enable = true;
          description = "Mute audio before suspend";
          wantedBy = [ "sleep.target" ];
          serviceConfig = {
            Type = "oneshot";
            User = "${vars.username}";
            ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
            RemainAfterExit = true;
          };
        };

        godoc = {
          enable = true;
          wantedBy = [ "multi-user.target" ];
          environment = {
            "GOPATH" = "/home/${vars.username}";
          };
          serviceConfig = {
            User = "${vars.username}";
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
    };

    system.stateVersion = "17.09";
    system.autoUpgrade.enable = true;
    system.autoUpgrade.channel = https://nixos.org/channels/nixos-17.09;
  }
