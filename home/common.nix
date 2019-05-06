{ config, pkgs, lib, ... }:

let
  localDir = "${config.home.homeDirectory}/.local";
  binDir = "${localDir}/bin";
  goBinDir = "${binDir}.go";
in
  {
    imports = [
      ./../modules/resources.nix
      ./git.nix
      ./gpg.nix
      ./zsh.nix
    ];

    config = with lib; mkMerge [
      (rec {
        accounts.email.accounts."${config.resources.email}" = {
          address = config.resources.email;
          gpg.encryptByDefault = true;
          gpg.key = config.resources.gpg.publicKey.fingerprint;
          gpg.signByDefault = true;
          primary = true;
        };

        home.file.".inputrc".text = ''
          $include /etc/inputrc
          set editing-mode vi
          set completion-ignore-case on
          set completion-prefix-display-length 2
          set show-all-if-ambiguous on
          set show-all-if-unmodified on
          set completion-map-case on
          Control-j: menu-complete
          Control-k: menu-complete-backward
        '';

        home.packages = with pkgs; [
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
          httpie
          jq
          kitty.terminfo
          lsof
          nix-prefetch-scripts
          nmap
          nox
          pandoc
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

        home.sessionVariables = with config.resources.programs; {
          __GL_SHADER_DISK_CACHE_PATH ="${xdg.cacheHome}/nv";
          BROWSER = browser.executable.path;
          CUDA_CACHE_PATH = "${xdg.cacheHome}/nv";
          EDITOR = editor.executable.path;
          ELINKS_CONFDIR = "${xdg.configHome}/elinks";
          EMAIL = config.resources.email;
          GIMP2_DIRECTORY = "${xdg.configHome}/gimp";
          HISTFILE = "${xdg.cacheHome}/shell-history";
          HISTFILESIZE = toString config.resources.histsize;
          HISTSIZE = toString config.resources.histsize;
          INPUTRC = "${xdg.configHome}/readline/inputrc";
          LESSHISTFILE = "${xdg.cacheHome}/less/history";
          MAILER = mailer.executable.path;
          PAGER = pager.executable.path;
          PYTHON_EGG_CACHE = "${xdg.cacheHome}/python-eggs";
          SAVEHIST = toString config.resources.histsize;
          VISUAL = editor.executable.path;
          WINEPREFIX = "${xdg.dataHome}/wine";
        };

        nixpkgs.config = import ./../nixpkgs/config.nix;
        nixpkgs.overlays = import ./../nixpkgs/overlays.nix;

        programs.bash.enable = true;
        programs.bash.enableAutojump = true;
        programs.bash.historyControl = [
          "erasedups"
          "ignoredups"
          "ignorespace"
        ];
        programs.bash.historyFile = home.sessionVariables.HISTFILE;
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
          binDir
          goBinDir
          "${xdg.dataHome}/npm/bin"
          "\${PATH}"
        ]);

        programs.zsh.shellAliases.d="${pkgs.docker}/bin/docker";
        programs.zsh.shellAliases.dc="${pkgs.docker_compose}/bin/docker-compose";
        programs.zsh.shellAliases.dck="${pkgs.docker_compose}/bin/docker-compose kill";
        programs.zsh.shellAliases.dcl="${pkgs.docker_compose}/bin/docker-compose logs";
        programs.zsh.shellAliases.dcp="${pkgs.docker_compose}/bin/docker-compose pull";
        programs.zsh.shellAliases.dcP="${pkgs.docker_compose}/bin/docker-compose push";
        programs.zsh.shellAliases.dcs="${pkgs.docker_compose}/bin/docker-compose start";
        programs.zsh.shellAliases.dcS="${pkgs.docker_compose}/bin/docker-compose stop";
        programs.zsh.shellAliases.dcu="${pkgs.docker_compose}/bin/docker-compose up";
        programs.zsh.shellAliases.dk="${pkgs.docker}/bin/docker kill";
        programs.zsh.shellAliases.dl="${pkgs.docker}/bin/docker logs";
        programs.zsh.shellAliases.dlt="${pkgs.docker}/bin/docker logs --tail 100";
        programs.zsh.shellAliases.dp="${pkgs.docker}/bin/docker ps";
        programs.zsh.shellAliases.dpq="${pkgs.docker}/bin/docker ps -q";

        xdg.cacheHome = "${localDir}/cache";
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
          XDG_DESKTOP_DIR="$HOME/.local/xdg/desktop"
          XDG_DOCUMENTS_DIR="$HOME/documents"
          XDG_DOWNLOAD_DIR="$HOME/downloads"
          XDG_MUSIC_DIR="$HOME/audio"
          XDG_PICTURES_DIR="$HOME/pictures"
          XDG_PUBLICSHARE_DIR="$HOME/.local/xdg/public"
          XDG_TEMPLATES_DIR="$HOME/.local/xdg/templates"
          XDG_VIDEOS_DIR="$HOME/video"
        '';
        xdg.configFile."user-dirs.locale".text = "en_US";
        xdg.configHome = "${config.home.homeDirectory}/.config";
        xdg.dataHome = "${localDir}/share";
        xdg.enable = true;
      })

      (mkIf pkgs.stdenv.isLinux rec {
        home.packages = with pkgs; [
          acpi
          dex
          espeak
          kitty.terminfo
          lm_sensors
          pciutils
          psmisc
          rfkill
          usbutils
        ];

        services.gpg-agent.defaultCacheTtl = 180000;
        services.gpg-agent.defaultCacheTtlSsh = 180000;
        services.gpg-agent.enable = true;
        services.gpg-agent.enableScDaemon = false;
        services.gpg-agent.enableSshSupport = true;
        services.gpg-agent.grabKeyboardAndMouse = false;

        services.syncthing.enable = false;
        services.syncthing.tray = config.resources.graphics.enable;

        systemd.user.startServices = true;
      })
    ];
  }
