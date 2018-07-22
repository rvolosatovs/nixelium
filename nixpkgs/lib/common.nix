{ config, pkgs, lib, graphical ? false, ... }:

let
  dotDir = "${config.home.homeDirectory}/.dotfiles";

  vars = import "${dotDir}/nixos/var/variables.nix" { inherit pkgs graphical; };

  localDir = "${config.home.homeDirectory}/.local";
  binDir = "${localDir}/bin";
  goBinDir = "${binDir}.go";

  secrets = import "${dotDir}/nixos/var/secrets.nix";

  #rubyVersion = "2.5.0";
  #rubyBinDir = "${config.home.homeDirectory}.gem/ruby/${rubyVersion}/bin";
in

rec {
  _module.args = {
    inherit dotDir vars secrets goBinDir;
  };

  imports =
  let
    base = [
      ./zsh.nix
      ./neovim.nix
      #./colors.nix
    ];
  in
  if !graphical then base
  else base ++ [ ./graphical.nix ];

  home.keyboard.layout = "lv,ru";
  home.keyboard.variant = "qwerty";
  home.keyboard.options = [
    "grp:alt_space_toggle"
    "terminate:ctrl_alt_bksp"
    "eurosign:5"
    "caps:escape"
  ];

  home.packages = with pkgs; [
    #gnum4
    acpi
    bench
    cowsay
    curl
    desktop_file_utils
    direnv
    docker-gc
    docker_compose
    espeak
    file
    fzf
    geoclue
    ghq
    git-lfs
    gnumake
    gnupg
    gnupg1compat
    graphviz
    htop
    httpie
    jq
    lf
    lm_sensors
    lsof
    ncdu
    neofetch
    nix-index
    nix-prefetch-scripts
    nix-repl
    nmap
    nox
    pandoc
    pass
    patchelf
    pciutils
    psmisc
    pv
    rclone
    rfkill
    ripgrep
    shellcheck
    sutils
    termite.terminfo
    tig
    tree
    universal-ctags
    unzip
    usbutils
    weechat
    wget
    whois
    wireguard
    xdg-user-dirs
    zip
  ];

  home.sessionVariables.BROWSER = vars.browser;
  home.sessionVariables.CUDA_CACHE_PATH = "${xdg.cacheHome}/nv";
  home.sessionVariables.EDITOR = vars.editor;
  home.sessionVariables.ELINKS_CONFDIR = "${xdg.configHome}/elinks";
  home.sessionVariables.EMAIL = vars.email;
  home.sessionVariables.GIMP2_DIRECTORY = "${xdg.configHome}/gimp";
  home.sessionVariables.GOBIN = goBinDir;
  home.sessionVariables.GOPATH = config.home.homeDirectory;
  home.sessionVariables.HISTFILE = "${xdg.cacheHome}/shell-history";
  home.sessionVariables.HISTFILESIZE = vars.histsize;
  home.sessionVariables.HISTSIZE = vars.histsize;
  home.sessionVariables.INPUTRC = "${xdg.configHome}/readline/inputrc";
  home.sessionVariables.LESSHISTFILE = "${xdg.cacheHome}/less/history";
  home.sessionVariables.MAILER = vars.mailer;
  home.sessionVariables.PAGER = vars.pager;
  home.sessionVariables.PASSWORD_STORE_DIR = "${localDir}/pass";
  home.sessionVariables.PYTHON_EGG_CACHE = "${xdg.cacheHome}/python-eggs";
  home.sessionVariables.SAVEHIST = vars.histsize;
  home.sessionVariables.VISUAL = vars.editor;
  home.sessionVariables.WINEPREFIX = "${xdg.dataHome}/wine";
  home.sessionVariables.__GL_SHADER_DISK_CACHE_PATH ="${xdg.cacheHome}/nv";

  nixpkgs.config = import "${dotDir}/nixpkgs/config.nix";

  programs.bash.enable = true;
  programs.bash.enableAutojump = true;
  programs.bash.historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
  programs.bash.historyFile = home.sessionVariables.HISTFILE;
  programs.bash.historyFileSize = home.sessionVariables.HISTFILESIZE;
  programs.bash.historySize = home.sessionVariables.HISTSIZE;
  programs.fzf.enable = true;
  programs.fzf.enableBashIntegration = true;
  programs.fzf.enableZshIntegration = true;
  programs.git.enable = true;
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
      default = upstream
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
    [ghq]
      root = ~/src
    [ghq "https://go.thethings.network"]
      vcs = git
  '';
  programs.git.userName = "Roman Volosatovs";
  programs.git.userEmail = vars.email;
  programs.home-manager.enable = true;
  programs.zsh.sessionVariables.PATH = lib.concatStringsSep ":" ([
    binDir
    goBinDir
    #rubyBinDir
    "${xdg.dataHome}/npm/bin"
    "\${PATH}"
  ]);

  #services.kbfs.enable = true;
  #services.kbfs.mountPoint = ".local/keybase";
  #services.keybase.enable = true;
  #services.syncthing.enable = true;
  #services.syncthing.tray = true;
  services.gpg-agent.defaultCacheTtl = 180000;
  services.gpg-agent.defaultCacheTtlSsh = 180000;
  services.gpg-agent.enable = true;
  services.gpg-agent.enableScDaemon = false;
  services.gpg-agent.enableSshSupport = true;
  services.gpg-agent.grabKeyboardAndMouse = false;

  systemd.user.startServices = true;

  xdg.enable = true;
  xdg.cacheHome = "${localDir}/cache";
  xdg.configFile."direnv/direnvrc".source = ../../direnv/direnvrc;
  xdg.configFile."git/gitignore".source = ../../git/gitignore;
  xdg.configFile."gocode/config.json".source = ../../gocode/config.json;
  xdg.configFile."htop/htoprc".source = ../../htop/htoprc;
  xdg.configFile."nixpkgs/config.nix".source = ../../nixpkgs/config.nix;
  xdg.configFile."rtorrent/rtorrent.rc".source = ../../rtorrent/rtorrent.rc;
  xdg.configFile."user-dirs.dirs".source = ../../user-dirs.dirs;
  xdg.configFile."user-dirs.locale".source = ../../user-dirs.locale;
  xdg.configHome = "${config.home.homeDirectory}/.config";
  xdg.dataHome = "${localDir}/share";
}
