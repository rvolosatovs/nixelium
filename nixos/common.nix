{ config, pkgs, lib, ... }:
{
  imports = [
    ./../modules/resources.nix
    #./multi-glibc-locale-paths.nix
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
  environment.shellAliases = {
    ll="ls -la";
    ls="ls -h --color=auto";
    mkdir="mkdir -pv";
    o="${pkgs.xdg_utils}/bin/xdg-open";
    ping="ping -c 3";
    rm="rm -i";
    sl="ls";
    sy="systemctl";
    Vi="sudoedit";
    Vim="sudoedit";
  };
  environment.shells = [
    config.resources.programs.shell.package
    pkgs.zsh
    pkgs.bashInteractive
  ];
  environment.systemPackages = with pkgs; [
    exfat
    kitty.terminfo
    libcgroup
    termite.terminfo
  ];

  home-manager.users.${config.resources.username} = {...}: {
    imports = [
      ./../home
    ];

    home.stateVersion = config.system.stateVersion;

    nixpkgs.overlays = config.nixpkgs.overlays;
    nixpkgs.config = config.nixpkgs.config;

    resources = config.resources;
  };

  i18n.consoleFont = "Lat2-Terminus16";
  i18n.consoleKeyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.firewall.enable = true;
  networking.extraHosts = builtins.readFile ./../vendor/hosts/hosts;

  nix.autoOptimiseStore = true;
  nix.binaryCaches = [
    "https://cache.nixos.org"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.gc.automatic = true;
  nix.nixPath = let
    infrastructure = (lib.sourceByRegex ./.. [ 
      "dotfiles"
      "dotfiles/.*"
      "home"
      "home/.*"
      "modules"
      "modules/.*"
      "nixos"
      "nixos/.*"
      "nixpkgs"
      "nixpkgs/.*"
      "resources"
      "resources/.*"
      "vendor"
      "vendor/copier"
      "vendor/copier/.*"
      "vendor/dumpster"
      "vendor/dumpster/.*"
      "vendor/gorandr"
      "vendor/gorandr/.*"
      "vendor/nur"
      "vendor/nur/.*"
    ]);
  in
  [
    "home-manager=https://github.com/rvolosatovs/home-manager/archive/stable.tar.gz"
    "nixos-config=${infrastructure}/nixos/hosts/${config.networking.hostName}"
    "nixpkgs-overlays=${infrastructure}/nixpkgs/overlays.nix"
    "nixpkgs-unstable=https://github.com/rvolosatovs/nixpkgs/archive/nixos-unstable.tar.gz"
    "nixpkgs=https://github.com/rvolosatovs/nixpkgs/archive/nixos.tar.gz"
  ];
  nix.optimise.automatic = true;
  nix.requireSignedBinaryCaches = true;
  nix.trustedUsers = [ "root" "${config.resources.username}" "@wheel" ];

  nixpkgs.config = import ./../nixpkgs/config.nix;
  nixpkgs.overlays = import ./../nixpkgs/overlays.nix;

  programs.bash.enableCompletion = true;

  programs.command-not-found.enable = true;

  programs.mosh.enable = true;

  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
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

      source "$(${pkgs.fzf}/bin/fzf-share)/completion.zsh"
      source "$(${pkgs.fzf}/bin/fzf-share)/key-bindings.zsh"
  '';
  programs.zsh.promptInit="";

  programs.zsh.syntaxHighlighting.enable = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.avahi.enable = true;

  services.fwupd.enable = true;

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

  system.stateVersion = "19.03";

  systemd.network.networks."40-virtualisation" = {
    matchConfig.Name = "virbr* veth* docker* br-*";
    linkConfig.Unmanaged = "yes";
    linkConfig.RequiredForOnline = false;
  };

  time.timeZone = "Europe/Amsterdam";

  users.defaultUserShell = config.resources.programs.shell.executable.path;
  users.groups.netdev = {};
  users.groups.plugdev = {};
  users.mutableUsers = false;
  users.users.${config.resources.username} = {
    extraGroups = [
      "adm"
      "audio"
      "dialout"
      "disk"
      "docker"
      "input"
      "libvirtd"
      "netdev"
      "plugdev"
      "ssh"
      "tty"
      "users"
      "uucp"
      "video"
      "wheel"
    ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = config.resources.ssh.publicKeys;
  };
  users.users.root.openssh.authorizedKeys.keys = config.resources.ssh.publicKeys;

  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.enable = true;

  virtualisation.libvirtd.enable = true;
}
