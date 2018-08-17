{ config, pkgs, lib, ... }:

{
  imports = [
    (import ../vendor/home-manager { inherit pkgs; }).nixos
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
  environment.sessionVariables = with config.meta.programs; {
    BROWSER = browser.executable.path;
    EDITOR = editor.executable.path;
    EMAIL = config.meta.email;
    HISTFILESIZE = toString config.meta.histsize;
    HISTSIZE = toString config.meta.histsize;
    MAILER = mailer.executable.path;
    PAGER = pager.executable.path;
    SAVEHIST = toString config.meta.histsize;
    VISUAL = editor.executable.path;
  };
  environment.shells = [
    config.meta.programs.shell.package
    pkgs.zsh
    pkgs.bashInteractive
  ];
  environment.systemPackages = with pkgs; [
    curl
    fzf
    git
    gnumake
    gnupg
    gnupg1compat
    htop
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
  ] ++ (with config.meta.programs; [
    browser.package
    editor.package
    mailer.package
    pager.package
    shell.package
    terminal.package
  ]);

  home-manager.users.${config.meta.username} = import ../home;

  i18n.consoleFont = "Lat2-Terminus16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.firewall.enable = true;
  networking.networkmanager.enable = true;

  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;
  nix.optimise.automatic = true;
  nix.trustedUsers = [ "root" "${config.meta.username}" "@wheel" ];
  nix.nixPath = with builtins; [
    "home-manager=${toPath ../vendor/home-manager}"
    "nixos-hardware=${toPath ./../vendor/nixos-hardware}"
    "nixpkgs=${toPath ./../vendor/nixpkgs}"
  ];

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

  services.geoclue2.enable = true;
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxRetentionSec=5day
  '';
  services.openssh.enable = true;
  services.openssh.hostKeys = [
    {
      type = "rsa";
      bits = 4096;
      path = "/etc/ssh/ssh_host_rsa_key";
      rounds = 100;
      openSSHFormat = true;
    }
    {
      type = "ed25519";
      path = "/etc/ssh/ssh_host_ed25519_key";
      rounds = 100;
    }
  ];
  services.openssh.passwordAuthentication = false;
  services.openssh.ports = config.meta.ssh.ports;
  services.openssh.startWhenNeeded = true;

  system.autoUpgrade.channel = https://nixos.org/channels/nixos-18.03;
  system.autoUpgrade.enable = false;
  system.stateVersion = "18.03";

  systemd.services.systemd-networkd-wait-online.enable = false;

  time.timeZone = "Europe/Amsterdam";

  users.defaultUserShell = config.meta.programs.shell.executable.path;
  users.mutableUsers = false;
  users.users.${config.meta.username} = {
    createHome = true;
    extraGroups = [
      "users" "wheel" "input" "audio" "video" "networkmanager"
      "docker" "dialout" "tty" "uucp" "disk" "adm" "wireshark"
      "mopidy" "vboxusers" "adbusers" "rkt" "libvirtd" "vboxusers" "ssh"
    ];
    hashedPassword = config.meta.user.hashedPassword;
    home = "/home/${config.meta.username}";
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.meta.ssh.publicKeys;
  };
  users.users.root.openssh.authorizedKeys.keys = config.meta.ssh.publicKeys;

  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
}
