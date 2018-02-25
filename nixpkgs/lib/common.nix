{ vars, unstable, lib, config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  localDir = "${homeDir}/.local";
  binDir = "${localDir}/bin";
  goBinDir = "${binDir}.go";

  #rubyVersion = "2.5.0";
  #rubyBinDir = "${homeDir}.gem/ruby/${rubyVersion}/bin";
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

  programs.home-manager.enable = true;
  programs.home-manager.path = xdg.configHome + "/nixpkgs/home-manager";
  programs.git.enable = true;
  programs.git.package = unstable.git;
  programs.git.aliases = {
    a = "apply --index";
    p = "format-patch --stdout";
    tree = "log --graph --pretty=format:'%C(auto)%h - %s [%an] (%C(blue)%ar)%C(auto)%d'";
    bigtree = "log --graph --decorate --pretty=format:'%C(auto)%d%n%h %s%+b%n(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n'";
    hist = "log --date=short --pretty=format:'%C(auto)%ad %h (%G?) %s [%an] %d'";
    xclean = "clean -xdf -e .envrc -e .direnv.* -e shell.nix -e default.nix -e vendor -e .vscode";
  };
  programs.git.extraConfig = ''
    [push]
      default = simple
    [status]
      short = true
      branch = true
      submoduleSummary = true
      showUntrackedFiles = all
    [color]
      ui = true
    [diff]
      renames = copy
    [branch]
      autosetuprebase = always
    [core]
      autocrlf = false
      safecrlf = false
      editor = ${pkgs.neovim}/bin/nvim
      excludesfile = ~/.config/git/gitignore
    [merge]
      tool = nvimdiff
      conflictstyle = diff3
    [diff]
      tool = nvimdiff
    [mergetool "nvimdiff"]
      cmd = ${pkgs.neovim}/bin/nvim -d $LOCAL $BASE $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'
    [format]
      pretty = %C(auto)%h - %s%d%n%+b%+N(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n
    [http]
      cookieFile = ~/.gitcookies
    [http "https://gopkg.in"]
      followRedirects = true
    [filter "lfs"]
      clean = git-lfs clean -- %f
      smudge = git-lfs smudge -- %f
      process = git-lfs filter-process
      required = true
    [rerere]
      enabled = true
  '';
  programs.git.signing.key = "3D80C89E";
  programs.git.signing.signByDefault = true;
  programs.git.userName = "Roman Volosatovs";
  programs.git.userEmail = vars.email;
  programs.zsh.sessionVariables.PATH = lib.concatStringsSep ":" ([
    binDir
    goBinDir
    #rubyBinDir
    "${xdg.dataHome}/npm/bin"
    "\${PATH}"
  ]);

  home.packages = with pkgs; [
    #httpie
    acpi
    bc
    clang
    cowsay
    curl
    desktop_file_utils
    elinks
    espeak
    file
    geoclue
    gist
    git-lfs
    gnum4
    gnumake
    gnupg
    gnupg1compat
    go-ethereum
    gotools
    graphviz
    grml-zsh-config
    haskellPackages.cabal-install
    haskellPackages.ghc
    htop
    julia
    lm_sensors
    lsof
    macchanger
    neofetch
    nix-index
    nix-prefetch-scripts
    nodejs
    pandoc
    pass
    patchelf
    pciutils
    python3Packages.pip
    playerctl
    poppler_utils
    protobuf
    psmisc
    pv
    python3
    rfkill
    ripgrep
    seth
    sutils
    tig
    tree
    universal-ctags
    unzip
    usbutils
    wget
    whois
    xdg-user-dirs
    zip
  ] ++ (with unstable; [
    direnv
    docker-gc
    docker_compose
    fzf
    go
    httpie
    jq
    #keybase
    #mopidy
    #neovim
    nix-repl
    nox
    rclone
    weechat
    wireguard
  ]);
}
