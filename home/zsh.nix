{ config, pkgs, ... }:

rec {
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.history.ignoreDups = true;
  programs.zsh.history.path = programs.zsh.dotDir + "/.zsh_history";
  programs.zsh.history.save = config.meta.histsize;
  programs.zsh.history.share = true;
  programs.zsh.history.size = config.meta.histsize;
  programs.zsh.initExtra = let 
    base16-shell = pkgs.copyPathToStore ../vendor/base16-shell;
  in ''
     { wego ''${CITY:-"Eindhoven"} 1 2>/dev/null | head -7 | tail -6 } &|

     nixify() {
       if [ ! -e ./.envrc ]; then
         echo "use nix" > .envrc
         ${pkgs.direnv}/bin/direnv allow
       fi

       nixfile="shell.nix"
       if [ -e "default.nix" ]; then
         nixfile="default.nix"
       fi

       if [ ! -e ''${nixfile} ]; then
         cat > ''${nixfile} <<'EOF'
     with import <nixpkgs> {};
     stdenv.mkDerivation {
       name = "env";
       buildInputs = [
         go
       ];
     }
     EOF
         ''${EDITOR:-'${config.meta.programs.editor.executable.path}'} ''${nixfile}
       fi
     }

     semver() {
       set -e

       majorX=`cut -d '.' -f1 <<< "''${1}"`
       majorX=''${majorX:-"0"}
       minorX=`cut -d '.' -f2 <<< "''${1}"`
       minorX=''${minorX:-"0"}
       patchX=`cut -d '.' -f3 <<< "''${1}"`
       patchX=''${patchX%-*}
       patchX=''${patchX:-"0"}

       majorY=`cut -d '.' -f1 <<< "''${2}"`
       majorY=''${majorY:-"0"}
       minorY=`cut -d '.' -f2 <<< "''${2}"`
       minorY=''${minorY:-"0"}
       patchY=`cut -d '.' -f3 <<< "''${2}"`
       patchY=''${patchY%-*}
       patchY=''${patchY:-"0"}

       extend() {
           v=''${1}
           while [ ''${#v} -lt ''${2} ]; do
               v=''${v}"0"
           done
           printf "%s" ''${v}
       }

       majorX=`extend ''${majorX} ''${#majorY}`
       minorX=`extend ''${minorX} ''${#minorY}`
       patchX=`extend ''${patchX} ''${#patchY}`

       majorY=`extend ''${majorY} ''${#majorX}`
       minorY=`extend ''${minorY} ''${#minorX}`
       patchY=`extend ''${patchY} ''${#patchX}`

       printf "%d%s%d\n" ''${majorX}''${minorX}''${patchX} ''${3:-" "} ''${majorY}''${minorY}''${patchY}
     }

     ver=( `semver ''${ZSH_VERSION} "5.3"` )
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

     bindkey -v

     if [ -n "$PS1" ] && [ -s "${base16-shell}/profile_helper.sh" ]; then
        eval "$("${base16-shell}/profile_helper.sh")"
     fi
     source ${config.xdg.dataHome}/base16/scripts/base16-tomorrow-night.sh
     source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  '';
  programs.zsh.profileExtra = ''
     [ -e ~/.nix-profile/etc/profile.d/nix.sh ] && source ~/.nix-profile/etc/profile.d/nix.sh
  '';
  programs.zsh.sessionVariables.KEYTIMEOUT = "1";
  programs.zsh.shellAliases.dh="dirs -v";
  programs.zsh.shellAliases.vi="nvim";
  programs.zsh.shellAliases.Vi="sudoedit";
  programs.zsh.shellAliases.Vim="sudoedit";
  programs.zsh.shellAliases.ne="nix-env";
  programs.zsh.shellAliases.nr="nixos-rebuild";
  programs.zsh.shellAliases.nu="sudo nixos-rebuild switch --upgrade -I nixpkgs=/nix/nixpkgs";
  programs.zsh.shellAliases.slow="nice -10";

  programs.zsh.shellAliases.ls="ls -h --color=auto";
  programs.zsh.shellAliases.ll="ls -la";
  programs.zsh.shellAliases.sl="ls";

  programs.zsh.shellAliases.rm="rm -i";

  programs.zsh.shellAliases.mkdir="mkdir -pv";

  programs.zsh.shellAliases.ping="ping -c 3";

  programs.zsh.shellAliases.o="xdg-open";
  programs.zsh.shellAliases.q="exit";

  programs.zsh.shellAliases.bd="popd";
  programs.zsh.shellAliases.nd="pushd";

  programs.zsh.shellAliases.go="richgo";

  programs.zsh.shellAliases.gs="git status";
  programs.zsh.shellAliases.gS="git show --word-diff=color";

  programs.zsh.shellAliases.gl="git log --stat --date=short";
  programs.zsh.shellAliases.gL="git log --word-diff=color --patch-with-stat";
  programs.zsh.shellAliases.gh="git hist";
  programs.zsh.shellAliases.gH="git hist --shortstat";
  programs.zsh.shellAliases.grl="git reflog";
  programs.zsh.shellAliases.gsl="git shortlog";
  programs.zsh.shellAliases.gt="git tree";
  programs.zsh.shellAliases.gT="git bigtree --summary --shortstat --dirstat";
  programs.zsh.shellAliases.gtt="gt --all";
  programs.zsh.shellAliases.gTT="gT --all";
  programs.zsh.shellAliases.gl1="gl --oneline";
  programs.zsh.shellAliases.gL1="gL --oneline";
  programs.zsh.shellAliases.gh1="gh --oneline";
  programs.zsh.shellAliases.gH1="gH --oneline";
  programs.zsh.shellAliases.gll="gl --all";
  programs.zsh.shellAliases.gLL="gL --all";
  programs.zsh.shellAliases.ghh="gh --all";
  programs.zsh.shellAliases.gHH="gH --all";
  programs.zsh.shellAliases.gd="git diff --word-diff=color";
  programs.zsh.shellAliases.ga="git add .";
  programs.zsh.shellAliases.gaf="git add";
  programs.zsh.shellAliases.gc="git commit";
  programs.zsh.shellAliases.gcm="git commit -m";
  programs.zsh.shellAliases.gca="git commit --amend";
  programs.zsh.shellAliases.gC="git commit -am";
  programs.zsh.shellAliases.gy="git stash";
  programs.zsh.shellAliases.gyp="git stash pop";
  programs.zsh.shellAliases.gyd="git stash drop";
  programs.zsh.shellAliases.gn="git checkout";
  programs.zsh.shellAliases.gnb="git checkout -b";
  programs.zsh.shellAliases.gno="git checkout --orphan";
  programs.zsh.shellAliases.gb="git branch";
  programs.zsh.shellAliases.gbi="git branch -lvv";
  programs.zsh.shellAliases.gr="git remote";
  programs.zsh.shellAliases.gB="git rebase";
  programs.zsh.shellAliases.gBc="git rebase --continue";
  programs.zsh.shellAliases.gBac="git add . && git rebase --continue";
  programs.zsh.shellAliases.gm="git cherry-pick";
  programs.zsh.shellAliases.gM="git merge";
  programs.zsh.shellAliases.gp="git pull";
  programs.zsh.shellAliases.gpp="git pull --prune";
  programs.zsh.shellAliases.gP="git push";
  programs.zsh.shellAliases.gPp="git push --prune";
  programs.zsh.shellAliases.gf="git fetch --all --prune";
  programs.zsh.shellAliases.gu="git submodule update --init --remote --rebase";
  programs.zsh.shellAliases.gR="git reset";
  programs.zsh.shellAliases.gRh="git reset --hard";
  programs.zsh.shellAliases.ge="git config --global --edit";

  programs.zsh.shellAliases.d="docker";
  programs.zsh.shellAliases.dl="docker logs";
  programs.zsh.shellAliases.dlt="docker logs --tail 100";
  programs.zsh.shellAliases.dp="docker ps";
  programs.zsh.shellAliases.dpq="docker ps -q";
  programs.zsh.shellAliases.dk="docker kill";
  programs.zsh.shellAliases.dc="docker-compose";
  programs.zsh.shellAliases.dcu="docker-compose up";
  programs.zsh.shellAliases.dcs="docker-compose start";
  programs.zsh.shellAliases.dcS="docker-compose stop";
  programs.zsh.shellAliases.dcl="docker-compose logs";
  programs.zsh.shellAliases.dcp="docker-compose pull";
  programs.zsh.shellAliases.dcP="docker-compose push";
  programs.zsh.shellAliases.dck="docker-compose kill";
  programs.zsh.shellAliases.sy="systemctl";
  programs.zsh.shellAliases.se="sudo systemctl enable";
  programs.zsh.shellAliases.sd="sudo systemctl disable";
  programs.zsh.shellAliases.ss="sudo systemctl start";
  programs.zsh.shellAliases.sS="sudo systemctl stop";
  programs.zsh.shellAliases.sr="sudo systemctl restart";

  programs.zsh.shellAliases.QQ="sudo systemctl poweroff";
  programs.zsh.shellAliases.RR="sudo systemctl reboot";
  programs.zsh.shellAliases.SS="sudo systemctl suspend";

  systemd.user.services.zsh-history-backup.Install.WantedBy=["default.target"];
  systemd.user.services.zsh-history-backup.Service.ExecStart="%h/.local/bin.go/copier -from %h/${programs.zsh.history.path} -to %h/${programs.zsh.history.path}.bkp";
  systemd.user.services.zsh-history-backup.Service.Restart="always";
  systemd.user.services.zsh-history-backup.Unit.Description="Backup zsh history file on every write, restore on every delete";

  xdg.configFile."zsh/.zshrc.local".source = ../dotfiles/zsh/zshrc.local;
}
