{ config, pkgs, lib, ... }:
{
  imports = [
    ./../modules/resources.nix
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
  environment.variables = with config.resources.programs; {
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
    ls="ls -h -G";
    mkdir="mkdir -pv";
    o="open";
    ping="ping -c 3";
    q="exit";
    rm="rm -i";
    sl="ls";
  };

  home-manager.useUserPackages = true;
  home-manager.users.${config.resources.username} = {...}: {
    imports = [
      ./../home
    ];

    nixpkgs.overlays = config.nixpkgs.overlays;
    nixpkgs.config = config.nixpkgs.config;

    resources = config.resources;
  };

  nix.binaryCaches = [
    "https://cache.nixos.org"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.nixPath = let
    infrastructure = (lib.sourceByRegex ./.. [
      "darwin"
      "darwin/.*"
      "dotfiles"
      "dotfiles/.*"
      "home"
      "home/.*"
      "modules"
      "modules/.*"
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
    "darwin-config=${infrastructure}/darwin/hosts/${config.networking.hostName}"
    "nixpkgs-overlays=${infrastructure}/nixpkgs/overlays.nix"
    "$HOME/.nix-defexpr/channels"
  ];
  nix.gc.automatic = true;
  nix.gc.user = "${config.resources.username}";
  nix.requireSignedBinaryCaches = true;
  nix.trustedUsers = [ "root" "${config.resources.username}" "@wheel" ];

  nixpkgs.config = import ./../nixpkgs/config.nix;
  nixpkgs.overlays = import ./../nixpkgs/overlays.nix;

  programs.bash.enable = true;
  programs.zsh.enable = true;

  system.stateVersion = 3;

  time.timeZone = "Europe/Amsterdam";

  users.knownUsers = [ config.resources.username ];
  users.users.${config.resources.username} = {
    home = "/Users/${config.resources.username}";
    createHome = true;
    shell = config.resources.programs.shell.executable.path;
    uid = 550;
  };
}
