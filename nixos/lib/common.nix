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

    shells = [ pkgs.zsh ];
    users.defaultUserShell = pkgs.zsh;
    users.users."${vars.username}" = {
      isNormalUser = true;
      initialPassword = "${vars.username}";
      home="/home/${vars.username}";
      createHome=true;
      extraGroups= [ "wheel" "input" "audio" "video" "networkmanager" "docker" "dialout" "tty" "uucp" "disk" "adm" "wireshark" ];
      openssh.authorizedKeys.keys = [
        keys.publicKey
      ];
    };

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

    environment.systemPackages = with pkgs; [
      lm_sensors
      pciutils
      lsof
      whois
      htop
      tree
      bc
      pv
      jq
      psmisc
      curl
      zip
      unzip
      gnumake
      wireguard
      git
      git-lfs
      fzf
      ripgrep
      neofetch
      rclone
      graphviz
      pandoc
      weechat
      rtorrent
      httpie
      unstable.neovim
      gnupg
      gnupg1compat
      grml-zsh-config
      xdg-user-dirs
      unstable.docker_compose
      docker-gc
      nox
      nix-repl
      rfkill
      unstable.direnv
    ];

    system.stateVersion = "17.09";
    system.autoUpgrade.enable = true;
  }
