{ vars, unstable, lib, config, pkgs, ... }:

let
    homeDir = config.home.homeDirectory;
    localDir = "${homeDir}/.local";
    binDir = "${localDir}/bin";
    goBinDir = "${binDir}.go";

    rubyVersion = "2.5.0";
    rubyBinDir = "${homeDir}.gem/ruby/${rubyVersion}/bin";
in

rec {
  imports = [
    (import ./zsh.nix { inherit config; inherit pkgs; xdg = config.xdg; })
    #./colors.nix
    ./neovim.nix
  ];

  systemd.user.startServices = true;

  #services.keybase.enable = true;
  #services.kbfs.enable = true;
  #services.kbfs.mountPoint = ".local/keybase";

  services.gpg-agent.enable = true;
  services.gpg-agent.defaultCacheTtl = 180000;
  services.gpg-agent.defaultCacheTtlSsh = 180000;
  services.gpg-agent.enableSshSupport = true;
  services.gpg-agent.enableScDaemon = false;
  services.gpg-agent.grabKeyboardAndMouse = false;

  #services.syncthing.enable = true;
  #services.syncthing.tray = true;

  xdg.enable = true;
  xdg.configHome = "${homeDir}/.config";
  xdg.cacheHome = "${localDir}/cache";
  xdg.dataHome = "${localDir}/share";

  home.sessionVariableSetter = "zsh";
  home.sessionVariables.EMAIL = vars.email;
  home.sessionVariables.EDITOR = vars.editor;
  home.sessionVariables.VISUAL = vars.editor;
  home.sessionVariables.BROWSER = vars.browser;
  home.sessionVariables.PAGER = vars.pager;

  home.sessionVariables.PASSWORD_STORE_DIR = "${localDir}/pass";

  home.sessionVariables.WINEPREFIX = "${xdg.dataHome}/wine";

  home.sessionVariables.LESSHISTFILE = "${xdg.cacheHome}/less/history";
  home.sessionVariables.__GL_SHADER_DISK_CACHE_PATH ="${xdg.cacheHome}/nv";
  home.sessionVariables.CUDA_CACHE_PATH = "${xdg.cacheHome}/nv";
  home.sessionVariables.PYTHON_EGG_CACHE = "${xdg.cacheHome}/python-eggs";

  home.sessionVariables.GIMP2_DIRECTORY = "${xdg.configHome}/gimp";
  home.sessionVariables.INPUTRC = "${xdg.configHome}/readline/inputrc";
  home.sessionVariables.ELINKS_CONFDIR = "${xdg.configHome}/elinks";

  home.sessionVariables.GOPATH = homeDir;
  home.sessionVariables.GOBIN = goBinDir;

  programs.zsh.sessionVariables.PATH = lib.concatStringsSep ":" ([
    binDir
    goBinDir
    rubyBinDir
    "${xdg.dataHome}/npm/bin"
    "\${PATH}"
  ]);

  home.packages = with pkgs; [
    acpi
    bc
    clang
    curl
    elinks
    espeak
    file
    gist
    git-lfs
    gnumake
    gnupg
    gnupg1compat
    go-ethereum
    gotools
    graphviz
    grml-zsh-config
    haskellPackages.ghc
    haskellPackages.cabal-install
    htop
    #httpie
    julia
    lm_sensors
    lsof
    neofetch
    nodejs
    pandoc
    pass
    pciutils
    playerctl
    poppler_utils
    protobuf
    psmisc
    pv
    rfkill
    ripgrep
    seth
    sutils
    tree
    universal-ctags
    unzip
    wget
    whois
    xdg-user-dirs
    zip
  ] ++ (with unstable; [
    direnv
    docker-gc
    docker_compose
    fzf
    git
    go
    httpie
    jq
    keybase
    #mopidy
    #neovim
    nix-repl
    nox
    rclone
    weechat
    wireguard
  ]);

  programs.home-manager.enable = true;
  programs.home-manager.path = xdg.configHome + "/nixpkgs/home-manager";
}
