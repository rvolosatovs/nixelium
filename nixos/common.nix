{ config, pkgs, lib, ... }:
let
  unstable = import <nixpkgs-unstable> {};
in
  {
    imports = [
      ./../modules/resources.nix
      ./multi-glibc-locale-paths.nix
    ];

    environment.extraInit = ''
      export PATH="$HOME/.local/bin:$HOME/.local/bin.go:$PATH"
    '';
    environment.interactiveShellInit = ''
      set -o vi
    '';
    environment.pathsToLink = [
      "/share/bash"
      "/share/zsh"
    ];
    environment.sessionVariables = with config.resources.programs; {
      BROWSER = browser.executable.path;
      EDITOR = editor.executable.path;
      EMAIL = config.resources.email;
      GIT_EDITOR = editor.executable.path;
      HISTFILESIZE = toString config.resources.histsize;
      HISTSIZE = toString config.resources.histsize;
      MAILER = mailer.executable.path;
      PAGER = pager.executable.path;
      SAVEHIST = toString config.resources.histsize;
      VISUAL = editor.executable.path;
    };
    environment.shells = [
      config.resources.programs.shell.package
      pkgs.zsh
      pkgs.bashInteractive
    ];
    environment.systemPackages = with pkgs; [
      exfat
      kitty.terminfo
      termite.terminfo
    ];

    home-manager.users.${config.resources.username} = {...}: {
      imports = [
        ./../home
      ];
      nixpkgs.overlays = config.nixpkgs.overlays;
    };

    i18n.consoleFont = "Lat2-Terminus16";
    i18n.consoleKeyMap = "us";
    i18n.defaultLocale = "en_US.UTF-8";

    networking.firewall.enable = true;
    networking.extraHosts = builtins.readFile ./../vendor/hosts/hosts;
    networking.networkmanager.enable = true;

    nix.autoOptimiseStore = true;
    nix.binaryCaches = [
      "https://rvolosatovs.cachix.org"
      "https://cache.nixos.org"
    ];
    nix.binaryCachePublicKeys = [
      "rvolosatovs.cachix.org-1:y1OANEBXt3SqDEUvPFqNHI/I5G7e34EAPIC4AjULqrw="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    nix.gc.automatic = true;
    nix.nixPath = with builtins; [
      "home-manager=${toPath ./../vendor/home-manager}"
      "nixos-hardware=${toPath ./../vendor/nixos-hardware}"
      "nixpkgs-unstable=${toPath ./../vendor/nixpkgs-unstable}"
      "nixpkgs=${toPath ./../vendor/nixpkgs}"
    ];
    nix.optimise.automatic = true;
    nix.requireSignedBinaryCaches = true;
    nix.trustedUsers = [ "root" "${config.resources.username}" "@wheel" ];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.neovim.vimAlias = true;
    nixpkgs.overlays = [
      (self: super: {
        inherit (unstable)
        bspwm
        dep
        cachix
        grml-zsh-config
        kitty
        neovim
        neovim-unwrapped
        platformio
        sway
        wine
        wineStaging
        ;
      })
    ];

    programs.bash.enableCompletion = true;
    programs.command-not-found.enable = true;
    programs.mosh.enable = true;
    programs.zsh.enable = true;
    programs.zsh.enableAutosuggestions = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.interactiveShellInit = ''
      [ -v oHISTFILE ] && echo "WARNING: oHISTFILE is getting overriden" &> 2
      oHISTFILE="$HISTFILE"

      [ -v oHISTSIZE ] && echo "WARNING: oHISTSIZE is getting overriden" &> 2
      oHISTSIZE="$HISTSIZE"

      [ -v oSAVEHIST ] && echo "WARNING: oSAVEHIST is getting overriden" &> 2
      oSAVEHIST="$SAVEHIST"

      source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"

      [ -v oHISTFILE ] && {export HISTFILE="$oHISTFILE"; unset oHISTFILE;}
      [ -v oHISTSIZE ] && {export HISTSIZE="$oHISTSIZE"; unset oHISTSIZE;}
      [ -v oSAVEHIST ] && {export SAVEHIST="$oSAVEHIST"; unset oSAVEHIST;}

      bindkey -v

      source "`${pkgs.fzf}/bin/fzf-share`/completion.zsh"
      source "`${pkgs.fzf}/bin/fzf-share`/key-bindings.zsh"
    '';
    programs.zsh.promptInit="";
    programs.zsh.syntaxHighlighting.enable = true;

    security.sudo.enable = true;
    security.sudo.wheelNeedsPassword = false;

    services.avahi.enable = true;
    services.fwupd.enable = true;
    services.geoclue2.enable = true;
    services.journald.extraConfig = ''
      SystemMaxUse=1G
      MaxRetentionSec=5day
    '';
    services.openssh.enable = true;
    services.openssh.hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
      }
    ];
    services.openssh.passwordAuthentication = false;
    services.openssh.startWhenNeeded = true;

    system.autoUpgrade.channel = https://nixos.org/channels/nixos-18.03;
    system.autoUpgrade.enable = false;
    system.stateVersion = "18.03";

    systemd.services.systemd-networkd-wait-online.enable = false;

    time.timeZone = "Europe/Amsterdam";

    users.defaultUserShell = config.resources.programs.shell.executable.path;
    users.mutableUsers = false;
    users.users.${config.resources.username} = {
      createHome = true;
      extraGroups = [
        "users" "wheel" "input" "audio" "video" "networkmanager"
        "docker" "dialout" "tty" "uucp" "disk" "adm" "libvirtd" "ssh"
      ];
      home = "/home/${config.resources.username}";
      isNormalUser = true;
      openssh.authorizedKeys.keys = config.resources.ssh.publicKeys;
    };
    users.users.root.openssh.authorizedKeys.keys = config.resources.ssh.publicKeys;

    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = true;
  }
