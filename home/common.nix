{ config, pkgs, lib, ... }:

let
  localDir = "${config.home.homeDirectory}/.local";
  binDir = "${localDir}/bin";
  goBinDir = "${binDir}.go";
in
  rec {
    imports = [
      ./../modules/meta.nix
      ./git.nix
      ./neovim.nix
      ./zsh.nix
    ];

    accounts.email.accounts.${config.meta.email}.address = config.meta.email;

    home.keyboard.layout = "lv,ru";
    home.keyboard.variant = "qwerty";
    home.keyboard.options = [
      "grp:alt_space_toggle"
      "terminate:ctrl_alt_bksp"
      "eurosign:5"
      "caps:escape"
    ];

    home.packages = with pkgs; [
      #bench
      #desktop_file_utils
      #direnv
      #geoclue
      #lf
      #ncdu
      #neofetch
      #patchelf
      #whois
      #wireguard
      #xdg-user-dirs
      acpi
      cowsay
      curl
      dex
      docker-gc
      docker_compose
      espeak
      file
      fzf
      ghq
      gnumake
      gnupg
      gnupg1compat
      graphviz
      htop
      httpie
      jq
      kitty.terminfo
      lm_sensors
      lsof
      nix-index
      nix-prefetch-scripts
      nmap
      nox
      pandoc
      pciutils
      psmisc
      pv
      rclone
      rfkill
      ripgrep
      shellcheck
      termite.terminfo
      tree
      universal-ctags
      unzip
      usbutils
      weechat
      wget
      zip
    ] ++ (with config.meta.programs; [
      browser.package
      editor.package
      mailer.package
      pager.package
      shell.package
    ]);

    home.sessionVariables = with config.meta.programs; {
      BROWSER = browser.executable.path;
      CUDA_CACHE_PATH = "${xdg.cacheHome}/nv";
      EDITOR = editor.executable.path;
      ELINKS_CONFDIR = "${xdg.configHome}/elinks";
      EMAIL = config.meta.email;
      GIMP2_DIRECTORY = "${xdg.configHome}/gimp";
      HISTFILE = "${xdg.cacheHome}/shell-history";
      HISTFILESIZE = toString config.meta.histsize;
      HISTSIZE = toString config.meta.histsize;
      INPUTRC = "${xdg.configHome}/readline/inputrc";
      LESSHISTFILE = "${xdg.cacheHome}/less/history";
      MAILER = mailer.executable.path;
      PAGER = pager.executable.path;
      PYTHON_EGG_CACHE = "${xdg.cacheHome}/python-eggs";
      SAVEHIST = toString config.meta.histsize;
      VISUAL = editor.executable.path;
      WINEPREFIX = "${xdg.dataHome}/wine";
      __GL_SHADER_DISK_CACHE_PATH ="${xdg.cacheHome}/nv";
    };

    nixpkgs.config = import ./../dotfiles/nixpkgs/config.nix;

    programs.bash.enable = true;
    programs.bash.enableAutojump = true;
    programs.bash.historyControl = [
      "erasedups"
      "ignoredups"
      "ignorespace"
    ];
    programs.bash.historyFile = home.sessionVariables.HISTFILE;
    programs.bash.historyFileSize = config.meta.histsize * 100;
    programs.bash.historySize = config.meta.histsize;
    programs.direnv.enable = true;
    programs.direnv.enableBashIntegration = true;
    programs.direnv.enableZshIntegration = true;
    programs.fzf.enable = true;
    programs.fzf.enableBashIntegration = true;
    programs.fzf.enableZshIntegration = true;
    programs.home-manager.enable = true;
    programs.home-manager.path = "${lib.toPath ./../vendor/home-manager}";
    programs.ssh.enable = true;
    programs.ssh.compression = true;
    programs.ssh.serverAliveInterval = 5;
    programs.ssh.matchBlocks."*".identityFile = "~/.ssh/id_ed25519";
    programs.ssh.matchBlocks."hashbang".hostname = "ny1.hashbang.sh";
    programs.ssh.matchBlocks."hashbang".identitiesOnly = true;
    programs.ssh.matchBlocks."hashbang".identityFile = "~/.ssh/id_ed25519";
    programs.ssh.matchBlocks."hashbang".user = config.meta.username;
    programs.ssh.matchBlocks."github.com".extraOptions.KexAlgorithms = "curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1";
    programs.ssh.matchBlocks."github.com".extraOptions.Ciphers = "chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr,aes256-cbc,aes192-cbc,aes128-cbc";
    programs.ssh.matchBlocks."github.com".extraOptions.MACs = "hmac-sha2-256,hmac-sha2-512,hmac-sha1";
    programs.zsh.sessionVariables.PATH = lib.concatStringsSep ":" ([
      binDir
      goBinDir
      "${xdg.dataHome}/npm/bin"
      "\${PATH}"
    ]);

    services.gpg-agent.defaultCacheTtl = 180000;
    services.gpg-agent.defaultCacheTtlSsh = 180000;
    services.gpg-agent.enable = true;
    services.gpg-agent.enableScDaemon = false;
    services.gpg-agent.enableSshSupport = true;
    services.gpg-agent.grabKeyboardAndMouse = false;
    services.syncthing.enable = true;
    services.syncthing.tray = config.meta.graphics.enable;

    systemd.user.startServices = true;

    xdg.cacheHome = "${localDir}/cache";
    xdg.configFile."direnv/direnvrc".source = ./../dotfiles/direnv/direnvrc;
    xdg.configFile."git/gitignore".source = ./../dotfiles/git/gitignore;
    xdg.configFile."gocode/config.json".source = ./../dotfiles/gocode/config.json;
    xdg.configFile."htop/htoprc".source = ./../dotfiles/htop/htoprc;
    xdg.configFile."nixpkgs/config.nix".source = ./../dotfiles/nixpkgs/config.nix;
    xdg.configFile."rtorrent/rtorrent.rc".source = ./../dotfiles/rtorrent/rtorrent.rc;
    xdg.configFile."user-dirs.dirs".source = ./../dotfiles/user-dirs.dirs;
    xdg.configFile."user-dirs.locale".source = ./../dotfiles/user-dirs.locale;
    xdg.configHome = "${config.home.homeDirectory}/.config";
    xdg.dataHome = "${localDir}/share";
    xdg.enable = true;
  }
