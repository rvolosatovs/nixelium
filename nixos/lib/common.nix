{ config, pkgs, secrets, vars, keys, unstable, ... }:

let
  mountOpts = if vars.isSSD then [ "noatime" "nodiratime" "discard" ] else [ "noatime" ] ;
in
  {
    environment.extraInit = ''
      export PATH="$HOME/.local/bin:$HOME/.local/bin.go:$PATH"
    '';
    environment.interactiveShellInit = ''
      set -o vi
    '';
    environment.pathsToLink = [ "/share/bash" "/share/zsh" ];
    environment.sessionVariables.BROWSER = vars.browser;
    environment.sessionVariables.EDITOR = vars.editor;
    environment.sessionVariables.EMAIL = vars.email;
    environment.sessionVariables.HISTFILESIZE = toString vars.histsize;
    environment.sessionVariables.HISTSIZE = toString vars.histsize;
    environment.sessionVariables.MAILER = vars.mailer;
    environment.sessionVariables.PAGER = vars.pager;
    environment.sessionVariables.SAVEHIST = toString vars.histsize;
    environment.sessionVariables.VISUAL = vars.editor;
    environment.shells = [ pkgs.zsh ];
    environment.systemPackages = with pkgs; [
      curl
      fzf
      git
      gnumake
      gnupg
      gnupg1compat
      htop
      httpie
      jq
      lm_sensors
      lsof
      neofetch
      neovim
      pciutils
      psmisc
      pv
      rfkill
      ripgrep
      termite.terminfo
      tree
      whois
      wireguard
      xdg-user-dirs
      zip
    ];

    fileSystems."/".options = mountOpts;
    fileSystems."/home".options = mountOpts;

    i18n.consoleFont = "Lat2-Terminus16";
    i18n.consoleKeyMap = "us";
    i18n.defaultLocale = "en_US.UTF-8";

    networking.firewall.enable = true;
    networking.hostName = vars.hostname;

    nix.autoOptimiseStore = true;
    nix.nixPath = [
      "nixpkgs=/nix/nixpkgs"
      "nixpkgs-unstable=/nix/var/nix/profiles/per-user/root/channels/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    nix.gc.automatic = true;
    nix.optimise.automatic = true;
    nix.trustedUsers = [ "root" "${vars.username}" "@wheel" ];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.neovim.vimAlias = true;

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

    services.openssh.enable = true;
    services.openssh.hostKeys = [
      { type = "rsa"; bits = 4096; path = "/etc/ssh/ssh_host_rsa_key"; rounds = 100; openSSHFormat = true; }
      { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; rounds = 100; comment = "key comment"; }
    ];
    #services.openssh.passwordAuthentication = true;
    services.openssh.passwordAuthentication = false;
    services.openssh.ports = secrets.ssh.ports;
    services.openssh.startWhenNeeded = true;
    services.journald.extraConfig = ''
      SystemMaxUse=1G
      MaxRetentionSec=5day
    '';

    system.autoUpgrade.channel = https://nixos.org/channels/nixos-18.03;
    system.autoUpgrade.enable = true;
    system.stateVersion = "18.03";

    systemd.services.systemd-networkd-wait-online.enable = false;

    time.timeZone = "Europe/Amsterdam";

    users.defaultUserShell = pkgs.zsh;
    users.users."${vars.username}" = {
      createHome = true;
      extraGroups = [ "users" "wheel" "input" "audio" "video" "networkmanager" "docker" "dialout" "tty" "uucp" "disk" "adm" "wireshark" "mopidy" "vboxusers" "adbusers" "rkt" "libvirtd" "vboxusers" "ssh" ];
      home = "/home/${vars.username}";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [ keys.publicKey ];
    };
    users.users.root.openssh.authorizedKeys.keys = [ keys.publicKey ];

    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.libvirtd.enable = true;
  }
