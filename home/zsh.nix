{
  config,
  pkgs,
  lib,
  ...
}: {
  config = with lib;
    mkMerge [
      {
        programs.zsh.dotDir = ".config/zsh";
        programs.zsh.enable = true;
        programs.zsh.enableAutosuggestions = true;
        programs.zsh.enableCompletion = true;
        programs.zsh.history.ignoreDups = true;
        programs.zsh.history.path = "${config.home.homeDirectory}/${config.programs.zsh.dotDir}/.zsh_history";
        programs.zsh.history.save = config.resources.histsize;
        programs.zsh.history.share = true;
        programs.zsh.history.size = config.resources.histsize;
        programs.zsh.initExtra = let
          # TODO: Derive hostnames from config
          hosts = [
            "neon"
            "oxygen"
            "zinc"
          ];

          # TODO: Turn into a module
          cdpath = [
            "${config.home.homeDirectory}/src/github.com/${config.resources.username}"
            "${config.home.homeDirectory}/src/github.com/profianinc"
            "${config.home.homeDirectory}/src/github.com/enarx"
            "${config.home.homeDirectory}/src/github.com"
            "${config.home.homeDirectory}/src/"
          ];
        in ''
          nixify() {
            if [ ! -e ./.envrc ]; then
              echo 'use flake' > .envrc
            fi
            nix flake new . -t "github:rvolosatovs/templates#''${1:-default}"
            ${pkgs.direnv}/bin/direnv allow
          }

          semver() {
            set -e

            majorX=$(cut -d '.' -f1 <<< "''${1}")
            majorX=''${majorX:-"0"}
            minorX=$(cut -d '.' -f2 <<< "''${1}")
            minorX=''${minorX:-"0"}
            patchX=$(cut -d '.' -f3 <<< "''${1}")
            patchX=''${patchX%-*}
            patchX=''${patchX:-"0"}

            majorY=$(cut -d '.' -f1 <<< "''${2}")
            majorY=''${majorY:-"0"}
            minorY=$(cut -d '.' -f2 <<< "''${2}")
            minorY=''${minorY:-"0"}
            patchY=$(cut -d '.' -f3 <<< "''${2}")
            patchY=''${patchY%-*}
            patchY=''${patchY:-"0"}

            extend() {
                v=''${1}
                while [ ''${#v} -lt ''${2} ]; do
                    v=''${v}"0"
                done
                printf "%s" ''${v}
            }

            majorX=$(extend ''${majorX} ''${#majorY})
            minorX=$(extend ''${minorX} ''${#minorY})
            patchX=$(extend ''${patchX} ''${#patchY})

            majorY=$(extend ''${majorY} ''${#majorX})
            minorY=$(extend ''${minorY} ''${#minorX})
            patchY=$(extend ''${patchY} ''${#patchX})

            printf "%d%s%d\n" ''${majorX}''${minorX}''${patchX} ''${3:-" "} ''${majorY}''${minorY}''${patchY}
          }

          ver=( $(semver ''${ZSH_VERSION} "5.3") )
          if [ ''${ver[1]} -ge ''${ver[2]} ]; then
           [ -v oHISTFILE ] && echo "WARNING: oHISTFILE is getting overriden" &> 2
           oHISTFILE="$HISTFILE"

           [ -v oHISTSIZE ] && echo "WARNING: oHISTSIZE is getting overriden" &> 2
           oHISTSIZE="$HISTSIZE"

           [ -v oSAVEHIST ] && echo "WARNING: oSAVEHIST is getting overriden" &> 2
           oSAVEHIST="$SAVEHIST"
          else
           oHISTFILE="$HISTFILE"
           oHISTSIZE="$HISTSIZE"
           oSAVEHIST="$SAVEHIST"
          fi

          export NO_ETC_HOSTS=1
          source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"

          if [ ''${ver[1]} -ge ''${ver[2]} ]; then
           [ -v oHISTFILE ] && {export HISTFILE="$oHISTFILE"; unset oHISTFILE;}
           [ -v oHISTSIZE ] && {export HISTSIZE="$oHISTSIZE"; unset oHISTSIZE;}
           [ -v oSAVEHIST ] && {export SAVEHIST="$oSAVEHIST"; unset oSAVEHIST;}
          else
           export HISTFILE="$oHISTFILE"
           export HISTSIZE="$oHISTSIZE"
           export SAVEHIST="$oSAVEHIST"
          fi

          base16_${config.resources.base16.theme}

          source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

          if (( EUID == 0 )); then
           umask 002
          else
           umask 022
          fi

          bindkey -M isearch . self-insert
          bindkey -M menuselect 'h' vi-backward-char        # left
          bindkey -M menuselect 'j' vi-down-line-or-history # bottom
          bindkey -M menuselect 'k' vi-up-line-or-history   # up
          bindkey -M menuselect 'l' vi-forward-char         # right
          bindkey -v
          cdpath=(${lib.concatStringsSep " " cdpath})
          setopt interactivecomments
          setopt NO_clobber
          setopt nocheckjobs
          setopt nonomatch
          zrcautoload predict-on
          zstyle ':completion:*' completer _complete _correct _approximate
          zstyle ':completion:*' completer _expand_alias _complete _approximate
          zstyle ':completion:*' expand prefix suffix
          zstyle ':completion:*:my-accounts' users-hosts {${config.resources.username},root}@{${lib.concatStringsSep "," hosts}}
          zstyle ':prompt:grml:right:setup' items
        '';
        programs.zsh.plugins = [
          {
            name = "base16-shell";
            src = ./../vendor/base16-shell;
          }
        ];
        programs.zsh.sessionVariables.KEYTIMEOUT = "1";

        programs.zsh.shellAliases.bd = "popd";
        programs.zsh.shellAliases.dh = "dirs -v";
        programs.zsh.shellAliases.nd = "pushd";
      }
    ];
}
