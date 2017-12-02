{ lib, config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  localDir = "${homeDir}/.local";
  binDir = "${localDir}/bin";
  goBinDir = "${binDir}.go";

  rubyVersion = "2.4.0";
  rubyBinDir = "${homeDir}.gem/ruby/${rubyVersion}/bin";

  unstable = import <nixpkgs-unstable> {};
  mypkgs = import <mypkgs> {};
  vars = import "${config.home.homeDirectory}/.dotfiles/nixos/var/variables.nix" { inherit pkgs; };
in

rec {
  imports = [
    (import ./zsh.nix { inherit config; inherit pkgs; xdg = config.xdg; })
    #./colors.nix
    ./neovim.nix
  ];

  xdg.enable = true;
  xdg.configHome = "${homeDir}/.config";
  xdg.cacheHome = "${localDir}/cache";
  xdg.dataHome = "${localDir}/share";

  home.sessionVariableSetter = "pam";
  home.packages = with pkgs; [
    bc
    curl
    elinks
    espeak
    git-lfs
    gnumake
    gnupg
    gnupg1compat
    grml-zsh-config
    htop
    lm_sensors
    lsof
    neofetch
    pciutils
    psmisc
    pv
    rfkill
    tree
    unzip
    whois
    xdg-user-dirs
    zip
  ] ++ (with unstable; [
    direnv
    docker-gc
    docker_compose
    fzf
    git
    httpie
    jq
    nox
    nix-repl
    rclone
    ripgrep
    weechat
    wireguard
  ]);

  home.sessionVariables.EMAIL=vars.email;
  home.sessionVariables.EDITOR=vars.editor;
  home.sessionVariables.VISUAL=vars.editor;
  home.sessionVariables.BROWSER=vars.browser;
  home.sessionVariables.PAGER=vars.pager;

  home.sessionVariables.GOPATH=homeDir;
  home.sessionVariables.GOBIN=goBinDir;
  home.sessionVariables.PATH=lib.concatStringsSep ":" ([
    binDir
    goBinDir
    rubyBinDir
    "${xdg.dataHome}/npm/bin"
    "\${PATH}"
  ]);

  home.sessionVariables.PASSWORD_STORE_DIR="${localDir}/pass";

  home.sessionVariables.WINEPREFIX="${xdg.dataHome}/wine";

  home.sessionVariables.LESSHISTFILE="${xdg.cacheHome}/less/history";
  home.sessionVariables.__GL_SHADER_DISK_CACHE_PATH="${xdg.cacheHome}/nv";
  home.sessionVariables.CUDA_CACHE_PATH="${xdg.cacheHome}/nv";
  home.sessionVariables.PYTHON_EGG_CACHE="${xdg.cacheHome}/python-eggs";

  home.sessionVariables.GIMP2_DIRECTORY="${xdg.configHome}/gimp";
  home.sessionVariables.INPUTRC="${xdg.configHome}/readline/inputrc";
  home.sessionVariables.ELINKS_CONFDIR="${xdg.configHome}/elinks";

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 180000;
    defaultCacheTtlSsh = 180000;
    enableSshSupport = true;
    enableScDaemon = false;
    grabKeyboardAndMouse = false;
  };
}
