{ config, pkgs, lib, ... }:

{
  imports = [
    ./../modules/resources.nix
    ./git.nix
    ./gpg.nix
    ./zsh.nix
  ];

  config = let
    baseNixPath = (lib.concatStringsSep ":" [
      "home-manager=${config.home.homeDirectory}/.nix-defexpr/channels/home-manager"
      "nixpkgs-unstable=${config.home.homeDirectory}/.nix-defexpr/channels/nixpkgs-unstable"
      "nixpkgs=${config.home.homeDirectory}/.nix-defexpr/channels/nixpkgs"
    ]) + "\${NIX_PATH:+:}\${NIX_PATH}";
  in with lib; mkMerge [
    ({
      accounts.email.accounts."${config.resources.email}" = {
        address = config.resources.email;
        primary = true;
      };

      home.packages = with pkgs; [
        (lib.lowPrio coreutils)
        cowsay
        curl
        docker-gc
        docker_compose
        file
        fzf
        ghq
        gnumake
        gnupg
        gnupg1compat
        graphviz
        htop
        jq
        kitty.terminfo
        lsof
        nix-prefetch-scripts
        nox
        pv
        rclone
        ripgrep
        shellcheck
        tree
        universal-ctags
        unzip
        weechat
        wget
        zip
      ] ++ (with config.resources.programs; [
        browser.package
        editor.package
        mailer.package
        pager.package
        shell.package
      ]);

      home.sessionVariables.__GL_SHADER_DISK_CACHE_PATH ="${config.xdg.cacheHome}/nv";
      home.sessionVariables.BROWSER = config.resources.programs.browser.executable.path;
      home.sessionVariables.CLICOLOR = "1";
      home.sessionVariables.CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
      home.sessionVariables.EDITOR = config.resources.programs.editor.executable.path;
      home.sessionVariables.ELINKS_CONFDIR = "${config.xdg.configHome}/elinks";
      home.sessionVariables.EMAIL = config.resources.email;
      home.sessionVariables.GIMP2_DIRECTORY = "${config.xdg.configHome}/gimp";
      home.sessionVariables.HISTFILE = "${config.xdg.cacheHome}/shell-history";
      home.sessionVariables.HISTFILESIZE = toString config.resources.histsize;
      home.sessionVariables.HISTSIZE = toString config.resources.histsize;
      home.sessionVariables.INPUTRC = pkgs.writeText "inputrc" ''
        $include /etc/inputrc
        set editing-mode vi
        $if term=linux
            set vi-ins-mode-string \1\e[?0c\2
            set vi-cmd-mode-string \1\e[?8c\2
        $else
            set vi-ins-mode-string \1\e[4 q\2
            set vi-cmd-mode-string \1\e[2 q\2
        $endif
        set colored-completion-prefix on
        set colored-stats on
        set completion-ignore-case on
        set completion-map-case on
        set completion-prefix-display-length 2
        set mark-symlinked-directories on
        set menu-complete-display-prefix on
        set show-all-if-ambiguous on
        set show-all-if-unmodified on
        set show-mode-in-prompt on
        set visible-stats on

        Control-j: menu-complete
        Control-k: menu-complete-backward
      '';
      home.sessionVariables.LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
      home.sessionVariables.LSCOLORS = "ExGxFxdaCxDaDahbadacec";
      home.sessionVariables.LS_COLORS = "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:";
      home.sessionVariables.MAILER = config.resources.programs.mailer.executable.path;
      home.sessionVariables.MANWIDTH = "80";
      home.sessionVariables.PAGER = config.resources.programs.pager.executable.path;
      home.sessionVariables.PYTHON_EGG_CACHE = "${config.xdg.cacheHome}/python-eggs";
      home.sessionVariables.SAVEHIST = toString config.resources.histsize;
      home.sessionVariables.VISUAL = config.resources.programs.editor.executable.path;
      home.sessionVariables.WINEPREFIX = "${config.xdg.dataHome}/wine";

      nixpkgs.config = import ./../nixpkgs/config.nix;
      nixpkgs.overlays = import ./../nixpkgs/overlays.nix;

      programs.bash.enable = true;
      programs.bash.enableAutojump = true;
      programs.bash.historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];
      programs.bash.historyFile = config.home.sessionVariables.HISTFILE;
      programs.bash.historyFileSize = config.resources.histsize * 100;
      programs.bash.historySize = config.resources.histsize;

      programs.direnv.enable = true;
      programs.direnv.enableBashIntegration = true;
      programs.direnv.enableZshIntegration = true;

      programs.fzf.enable = true;
      programs.fzf.enableBashIntegration = true;
      programs.fzf.enableZshIntegration = true;

      programs.home-manager.enable = true;
      programs.home-manager.path = ./../vendor/home-manager;

      programs.ssh.enable = true;
      programs.ssh.compression = true;
      programs.ssh.serverAliveInterval = 5;
      programs.ssh.matchBlocks."*".identityFile = "~/.ssh/id_ed25519";
      programs.ssh.matchBlocks."hashbang".hostname = "ny1.hashbang.sh";
      programs.ssh.matchBlocks."hashbang".identitiesOnly = true;
      programs.ssh.matchBlocks."hashbang".identityFile = "~/.ssh/id_ed25519";
      programs.ssh.matchBlocks."hashbang".user = config.resources.username;
      programs.ssh.matchBlocks."github.com".extraOptions.KexAlgorithms = "curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1";
      programs.ssh.matchBlocks."github.com".extraOptions.Ciphers = "chacha20-poly1305@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr,aes256-cbc,aes192-cbc,aes128-cbc";
      programs.ssh.matchBlocks."github.com".extraOptions.MACs = "hmac-sha2-256,hmac-sha2-512,hmac-sha1";

      programs.zsh.sessionVariables.PATH = lib.concatStringsSep ":" ([
        "${config.home.homeDirectory}/.local/bin"
        "${config.home.homeDirectory}/.local/bin.go"
        "${config.xdg.dataHome}/npm/bin"
        "\${PATH}"
      ]);

      programs.zsh.shellAliases.d = "${pkgs.docker}/bin/docker";
      programs.zsh.shellAliases.dc = "${pkgs.docker_compose}/bin/docker-compose";
      programs.zsh.shellAliases.dck = "${pkgs.docker_compose}/bin/docker-compose kill";
      programs.zsh.shellAliases.dcl = "${pkgs.docker_compose}/bin/docker-compose logs";
      programs.zsh.shellAliases.dcp = "${pkgs.docker_compose}/bin/docker-compose pull";
      programs.zsh.shellAliases.dcP = "${pkgs.docker_compose}/bin/docker-compose push";
      programs.zsh.shellAliases.dcs = "${pkgs.docker_compose}/bin/docker-compose start";
      programs.zsh.shellAliases.dcS = "${pkgs.docker_compose}/bin/docker-compose stop";
      programs.zsh.shellAliases.dcu = "${pkgs.docker_compose}/bin/docker-compose up";
      programs.zsh.shellAliases.dk = "${pkgs.docker}/bin/docker kill";
      programs.zsh.shellAliases.dl = "${pkgs.docker}/bin/docker logs";
      programs.zsh.shellAliases.dlt = "${pkgs.docker}/bin/docker logs --tail 100";
      programs.zsh.shellAliases.dp = "${pkgs.docker}/bin/docker ps";
      programs.zsh.shellAliases.dpq = "${pkgs.docker}/bin/docker ps -q";
      programs.zsh.shellAliases.ll = "${pkgs.coreutils}/bin/ls -la";
      programs.zsh.shellAliases.ls = "${pkgs.coreutils}/bin/ls -h --color=auto";
      programs.zsh.shellAliases.mkdir = "${pkgs.coreutils}/bin/mkdir -pv";
      programs.zsh.shellAliases.rm = "${pkgs.coreutils}/bin/rm -i";
      programs.zsh.shellAliases.sl = "${pkgs.coreutils}/bin/ls";

      xdg.cacheHome = "${config.home.homeDirectory}/.local/cache";
      xdg.configFile."direnv/direnvrc".source = ./../dotfiles/direnv/direnvrc;
      xdg.configFile."htop/htoprc".text = ''
        account_guest_in_cpu_meter=0
        color_scheme=0
        cpu_count_from_zero=0
        delay=15
        detailed_cpu_time=0
        fields=0 48 17 18 38 39 40 2 46 47 49 1
        header_margin=1
        hide_kernel_threads=1
        hide_threads=0
        hide_userland_threads=0
        highlight_base_name=0
        highlight_megabytes=1
        highlight_threads=1
        left_meter_modes=1 1 1
        left_meters=AllCPUs Memory Swap
        right_meter_modes=2 2 2
        right_meters=Tasks LoadAverage Uptime
        shadow_other_users=0
        show_program_path=1
        show_thread_names=0
        sort_direction=1
        sort_key=46
        tree_view=0
        update_process_names=0
      '';
      xdg.configFile."nixpkgs/config.nix".source = ./../nixpkgs/config.nix;
      xdg.configFile."user-dirs.dirs".text = ''
        XDG_DESKTOP_DIR="${config.home.homeDirectory}/.local/xdg/desktop"
        XDG_DOCUMENTS_DIR="${config.home.homeDirectory}/documents"
        XDG_DOWNLOAD_DIR="${config.home.homeDirectory}/downloads"
        XDG_MUSIC_DIR="${config.home.homeDirectory}/audio"
        XDG_PICTURES_DIR="${config.home.homeDirectory}/pictures"
        XDG_PUBLICSHARE_DIR="${config.home.homeDirectory}/.local/xdg/public"
        XDG_TEMPLATES_DIR="${config.home.homeDirectory}/.local/xdg/templates"
        XDG_VIDEOS_DIR="${config.home.homeDirectory}/video"
      '';
      xdg.configFile."user-dirs.locale".text = "en_US";
      xdg.configHome = "${config.home.homeDirectory}/.config";
      xdg.dataHome = "${config.home.homeDirectory}/.local/share";
      xdg.enable = true;
    })

    (mkIf pkgs.stdenv.isDarwin {
      home.file.".terminfo".source = "/etc/profiles/per-user/${config.resources.username}/share/terminfo";

      home.sessionVariables.NIX_PATH = "darwin=${config.home.homeDirectory}/.nix-defexpr/channels/darwin:${baseNixPath}";

      programs.zsh.shellAliases.o = "open";
      programs.zsh.shellAliases.ping = "/sbin/ping -c 3";
    })

    (mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        acpi
        dex
        espeak
        lm_sensors
        pciutils
        psmisc
        rfkill
        sudo
        usbutils
      ];

      home.sessionVariables.NIX_PATH = baseNixPath;

      programs.zsh.shellAliases.o = "${pkgs.xdg_utils}/bin/xdg-open";
      programs.zsh.shellAliases.ping = "/run/wrappers/bin/ping -c 3";
      programs.zsh.shellAliases.sy="${pkgs.systemd}/bin/systemctl";
      programs.zsh.shellAliases.Vi = "/run/wrappers/bin/sudoedit";
      programs.zsh.shellAliases.Vim = "/run/wrappers/bin/sudoedit";

      services.syncthing.enable = false;
      services.syncthing.tray = config.resources.graphics.enable;

      systemd.user.startServices = true;
    })
  ];
}
