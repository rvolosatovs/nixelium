{ pkgs, homeDir, username, ... }:

let
  #homeDir = username: "/home/${username}";

  unstable = import <nixpkgs-unstable> {};
  mypkgs = import <mypkgs> {};
  vars = import /etc/nixos/variables.nix { pkgs=pkgs; };

  rubyVersion = "2.4.0";

  localDir = "${vars.homeDir}/.local";

  xdgConfigHome = "${vars.homeDir}/.config";
  xdgCacheHome = "${localDir}/cache";
  xdgDataHome = "${localDir}/share";

  passwordStoreDir = "${localDir}/pass";

  goPath = "${vars.homeDir}";
  goBinDir = "${localDir}/bin.go";

  binDir = "${localDir}/bin";
  rubyBinDir = "${vars.homeDir}/.gem/ruby/${rubyVersion}/bin";
in

{
  imports = [
    ./local.nix
  ];
  home = {
    packages = with pkgs; [
      htop
      neovim
      curl
      git
      docker_compose
      pv
      fzf
      #ripgrep
      zsh-syntax-highlighting
    ];
    sessionVariables = {
      EMAIL="${vars.email}";
      EDITOR="${vars.editor}";
      VISUAL="${vars.editor}";
      BROWSER="${vars.browser}";
      PAGER="${vars.pager}";

      QT_QPA_PLATFORMTHEME="gtk2";

      XDG_CONFIG_HOME="${xdgConfigHome}";
      XDG_CACHE_HOME="${xdgCacheHome}";
      XDG_DATA_HOME="${xdgDataHome}";

      PASSWORD_STORE_DIR="${localDir}/pass";

      GOPATH="${vars.homeDir}";
      GOBIN="${goBinDir}";
      #PATH=[ "${binDir}" "${goBinDir}" "${rubyBinDir}" ];

      WINEPREFIX="${xdgDataHome}/wine";

      TMUX_TMPDIR="\${XDG_RUNTIME_DIR}/tmux";

      LESSHISTFILE="${xdgCacheHome}/less/history";
      __GL_SHADER_DISK_CACHE_PATH="${xdgCacheHome}/nv";
      CUDA_CACHE_PATH="${xdgCacheHome}/nv";
      PYTHON_EGG_CACHE="${xdgCacheHome}/python-eggs";

      GIMP2_DIRECTORY="${xdgConfigHome}/gimp";
      #GNUPGHOME="${xdgConfigHome}/gnupg";
      #GTK2_RC_FILES="${xdgConfigHome}/gtk-2.0/gtkrc";
      INPUTRC="${xdgConfigHome}/readline/inputrc";
      ELINKS_CONFDIR="${xdgConfigHome}/elinks";

      #ZDOTDIR="${xdgConfigHome}/zsh"; # set by zsh subm
      ZPLUG_HOME="${xdgConfigHome}/zsh/zplug";
    };
    sessionVariableSetter = "pam";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 180000;
    defaultCacheTtlSsh = 180000;
    writeEnvFile = "${xdgCacheHome}/gpg-agent-info";
    enableSshSupport = true;
    disableScDaemon = true;
    noGrab = true;
  };

  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      dotDir = ".config/zsh";
      initExtra = ''
        source "${pkgs.grml-zsh-config}/etc/zsh/zshrc";
        bindkey -v
        source "`${pkgs.fzf}/bin/fzf-share`/completion.zsh"
        source "`${pkgs.fzf}/bin/fzf-share`/key-bindings.zsh"

        CITY=''${CITY:-"Eindhoven"}
        { curl -s wttr.in/''${CITY} 2>/dev/null | head -7 } &|

        source ~/.local/share/base16/scripts/base16-tomorrow-night.sh
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      '';
      history.path = ".zhistory";
      shellAliases= {
        dh="dirs -v";
        vi="nvim";
        vim="nvim";
        Vi="sudoedit";
        Vim="sudoedit";
        ni="nix-env -i";
        ne="nix-env -e";
        nu="nix-env -u";
        ns="nox";
        slow="nice -10";

        ls="ls -h --color=auto";
        ll="ls -la";
        sl="ls";

        rm="rm -i";

        mkdir="mkdir -pv";

        ping="ping -c 3";

        o="xdg-open";
        q="exit";

        bd="popd";
        nd="pushd";

        go="richgo";

        gs="git status";
        gS="git show --word-diff=color";

        gl="git log --stat --date=short";
        gL="git log --word-diff=color --patch-with-stat";
        gh="git hist";
        gH="git hist --shortstat";
        grl="git reflog";
        gsl="git shortlog";
        gt="git tree";
        gT="git bigtree --summary --shortstat --dirstat";
        gtt="gt --all";
        gTT="gT --all";
        gl1="gl --oneline";
        gL1="gL --oneline";
        gh1="gh --oneline";
        gH1="gH --oneline";
        gll="gl --all";
        gLL="gL --all";
        ghh="gh --all";
        gHH="gH --all";
        gd="git diff --word-diff=color";
        ga="git add .";
        gaf="git add";
        gc="git commit";
        gcm="git commit -m";
        gca="git commit --amend";
        gC="git commit -am";
        gy="git stash";
        gyp="git stash pop";
        gyd="git stash drop";
        gn="git checkout";
        gnb="git checkout -b";
        gno="git checkout --orphan";
        gb="git branch";
        gbi="git branch -lvv";
        gr="git remote";
        gB="git rebase";
        gm="git cherry-pick";
        gM="git merge";
        gp="git pull";
        gpp="git pull --prune";
        gP="git push";
        gPp="git push --prune";
        gf="git fetch";
        gfp="git fetch --prune";
        gu="git submodule update --init --remote --rebase";
        gR="git reset";
        gRh="git reset --hard";
        ge="git config --global --edit";
        d="docker";
        dl="docker logs";
        dlt="docker logs --tail 100";
        dp="docker ps";
        dpq="docker ps -q";
        dk="docker kill";
        dc="docker-compose";
        dcu="docker-compose up";
        dcs="docker-compose start";
        dcS="docker-compose stop";
        dcl="docker-compose logs";
        dcp="docker-compose pull";
        dcP="docker-compose push";
        dck="docker-compose kill";
        sy="systemctl";
        se="sudo systemctl enable";
        sd="sudo systemctl disable";
        ss="sudo systemctl start";
        sS="sudo systemctl stop";
        sr="sudo systemctl restart";

        QQ="sudo systemctl poweroff";
        RR="sudo systemctl reboot";
        SS="sudo systemctl suspend";
      };
    };
  };

  gtk = {
    enable = true;
    fontName = "Sans 10";
    themeName = "oomox-Tomorrow-Dark";
    iconThemeName = "oomox-Tomorrow-Dark-flat";
    gtk2 = {
      extraConfig = ''
        gtk-cursor-theme-size=0
        gtk-toolbar-style=GTK_TOOLBAR_BOTH
        gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
        gtk-button-images=1
        gtk-menu-images=1
        gtk-enable-event-sounds=1
        gtk-enable-input-feedback-sounds=1
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
    };
    gtk3 = {
      extraConfig = {
        gtk-cursor-theme-size=0;
        gtk-toolbar-style="GTK_TOOLBAR_BOTH";
        gtk-toolbar-icon-size="GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-button-images=1;
        gtk-menu-images=1;
        gtk-enable-event-sounds=1;
        gtk-enable-input-feedback-sounds=1;
        gtk-xft-antialias=1;
        gtk-xft-hinting=1;
        gtk-xft-hintstyle="hintslight";
        gtk-xft-rgba="rgb";
      };
      extraCss = ''
        .window-frame, .window-frame:backdrop {
          box-shadow: 0 0 0 black;
          border-style: none;
          margin: 0;
          border-radius: 0;
        }
        .titlebar {
          border-radius: 0;
        }
        window decoration {
          margin: 0;
          border: 0;
        }
      '';
    };
  };

}
