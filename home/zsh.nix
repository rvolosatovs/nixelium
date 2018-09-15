{ config, pkgs, ... }:

rec {
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.history.ignoreDups = true;
  programs.zsh.history.path = programs.zsh.dotDir + "/.zsh_history";
  programs.zsh.history.save = config.resources.histsize;
  programs.zsh.history.share = true;
  programs.zsh.history.size = config.resources.histsize;
  programs.zsh.initExtra = ''
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
         ''${EDITOR:-'${config.resources.programs.editor.executable.path}'} ''${nixfile}
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

     base16_${config.resources.base16.theme}

     source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

     bindkey -v
  '';
  programs.zsh.plugins = [
    {
      name = "base16-shell";
      src = pkgs.copyPathToStore ../vendor/base16-shell;
    }
  ];
  programs.zsh.profileExtra = ''
     [ -e ~/.nix-profile/etc/profile.d/nix.sh ] && source ~/.nix-profile/etc/profile.d/nix.sh
  '';
  programs.zsh.sessionVariables.KEYTIMEOUT = "1";

  programs.zsh.shellAliases.bd="popd";
  programs.zsh.shellAliases.d="${pkgs.docker}/bin/docker";
  programs.zsh.shellAliases.dc="${pkgs.docker-compose}/bin/docker-compose";
  programs.zsh.shellAliases.dck="${pkgs.docker-compose}/bin/docker-compose kill";
  programs.zsh.shellAliases.dcl="${pkgs.docker-compose}/bin/docker-compose logs";
  programs.zsh.shellAliases.dcp="${pkgs.docker-compose}/bin/docker-compose pull";
  programs.zsh.shellAliases.dcP="${pkgs.docker-compose}/bin/docker-compose push";
  programs.zsh.shellAliases.dcs="${pkgs.docker-compose}/bin/docker-compose start";
  programs.zsh.shellAliases.dcS="${pkgs.docker-compose}/bin/docker-compose stop";
  programs.zsh.shellAliases.dcu="${pkgs.docker-compose}/bin/docker-compose up";
  programs.zsh.shellAliases.dh="dirs -v";
  programs.zsh.shellAliases.dk="${pkgs.docker}/bin/docker kill";
  programs.zsh.shellAliases.dl="${pkgs.docker}/bin/docker logs";
  programs.zsh.shellAliases.dlt="${pkgs.docker}/bin/docker logs --tail 100";
  programs.zsh.shellAliases.dp="${pkgs.docker}/bin/docker ps";
  programs.zsh.shellAliases.dpq="${pkgs.docker}/bin/docker ps -q";
  programs.zsh.shellAliases.ga="${pkgs.git}/bin/git add .";
  programs.zsh.shellAliases.gaf="${pkgs.git}/bin/git add";
  programs.zsh.shellAliases.gb="${pkgs.git}/bin/git branch";
  programs.zsh.shellAliases.gB="${pkgs.git}/bin/git rebase";
  programs.zsh.shellAliases.gBac="${pkgs.git}/bin/git add . && git rebase --continue";
  programs.zsh.shellAliases.gBc="${pkgs.git}/bin/git rebase --continue";
  programs.zsh.shellAliases.gbi="${pkgs.git}/bin/git branch -lvv";
  programs.zsh.shellAliases.gC="${pkgs.git}/bin/git commit -am";
  programs.zsh.shellAliases.gc="${pkgs.git}/bin/git commit";
  programs.zsh.shellAliases.gca="${pkgs.git}/bin/git commit --amend";
  programs.zsh.shellAliases.gcm="${pkgs.git}/bin/git commit -m";
  programs.zsh.shellAliases.gd="${pkgs.git}/bin/git diff --word-diff=color";
  programs.zsh.shellAliases.ge="${pkgs.git}/bin/git config --global --edit";
  programs.zsh.shellAliases.gf="${pkgs.git}/bin/git fetch --all --prune";
  programs.zsh.shellAliases.gh1="${programs.zsh.shellAliases.gh} --oneline";
  programs.zsh.shellAliases.gH1="${programs.zsh.shellAliases.gH} --oneline";
  programs.zsh.shellAliases.gH="${pkgs.git}/bin/git hist --shortstat";
  programs.zsh.shellAliases.gh="${pkgs.git}/bin/git hist";
  programs.zsh.shellAliases.ghh="${programs.zsh.shellAliases.gh} --all";
  programs.zsh.shellAliases.gHH="${programs.zsh.shellAliases.gH} --all";
  programs.zsh.shellAliases.gl1="${programs.zsh.shellAliases.gl} --oneline";
  programs.zsh.shellAliases.gL1="${programs.zsh.shellAliases.gL} --oneline";
  programs.zsh.shellAliases.gl="${pkgs.git}/bin/git log --stat --date=short";
  programs.zsh.shellAliases.gL="${pkgs.git}/bin/git log --word-diff=color --patch-with-stat";
  programs.zsh.shellAliases.gll="${programs.zsh.shellAliases.gl} --all";
  programs.zsh.shellAliases.gLL="${programs.zsh.shellAliases.gL} --all";
  programs.zsh.shellAliases.gm="${pkgs.git}/bin/git cherry-pick";
  programs.zsh.shellAliases.gM="${pkgs.git}/bin/git merge";
  programs.zsh.shellAliases.gn="${pkgs.git}/bin/git checkout";
  programs.zsh.shellAliases.gnb="${pkgs.git}/bin/git checkout -b";
  programs.zsh.shellAliases.gno="${pkgs.git}/bin/git checkout --orphan";
  programs.zsh.shellAliases.gp="${pkgs.git}/bin/git pull";
  programs.zsh.shellAliases.gP="${pkgs.git}/bin/git push";
  programs.zsh.shellAliases.gpp="${pkgs.git}/bin/git pull --prune";
  programs.zsh.shellAliases.gPp="${pkgs.git}/bin/git push --prune";
  programs.zsh.shellAliases.gr="${pkgs.git}/bin/git remote";
  programs.zsh.shellAliases.gR="${pkgs.git}/bin/git reset";
  programs.zsh.shellAliases.gRh="${pkgs.git}/bin/git reset --hard";
  programs.zsh.shellAliases.grl="${pkgs.git}/bin/git reflog";
  programs.zsh.shellAliases.gS="${pkgs.git}/bin/git show --word-diff=color";
  programs.zsh.shellAliases.gs="${pkgs.git}/bin/git status";
  programs.zsh.shellAliases.gsl="${pkgs.git}/bin/git shortlog";
  programs.zsh.shellAliases.gT="${pkgs.git}/bin/git bigtree --summary --shortstat --dirstat";
  programs.zsh.shellAliases.gt="${pkgs.git}/bin/git tree";
  programs.zsh.shellAliases.gtt="${programs.zsh.shellAliases.gt} --all";
  programs.zsh.shellAliases.gTT="${programs.zsh.shellAliases.gT} --all";
  programs.zsh.shellAliases.gy="${pkgs.git}/bin/git stash";
  programs.zsh.shellAliases.gyd="${pkgs.git}/bin/git stash drop";
  programs.zsh.shellAliases.gyp="${pkgs.git}/bin/git stash pop";
  programs.zsh.shellAliases.ll="ls -la";
  programs.zsh.shellAliases.ls="ls -h --color=auto";
  programs.zsh.shellAliases.mkdir="mkdir -pv";
  programs.zsh.shellAliases.nd="pushd";
  programs.zsh.shellAliases.o="xdg-open";
  programs.zsh.shellAliases.ping="ping -c 3";
  programs.zsh.shellAliases.q="exit";
  programs.zsh.shellAliases.QQ="sudo systemctl poweroff";
  programs.zsh.shellAliases.rm="rm -i";
  programs.zsh.shellAliases.RR="sudo systemctl reboot";
  programs.zsh.shellAliases.sd="sudo systemctl disable";
  programs.zsh.shellAliases.se="sudo systemctl enable";
  programs.zsh.shellAliases.sl="ls";
  programs.zsh.shellAliases.sr="sudo systemctl restart";
  programs.zsh.shellAliases.ss="sudo systemctl start";
  programs.zsh.shellAliases.sS="sudo systemctl stop";
  programs.zsh.shellAliases.SS="sudo systemctl suspend";
  programs.zsh.shellAliases.sy="systemctl";
  programs.zsh.shellAliases.Vi="sudoedit";
  programs.zsh.shellAliases.Vim=programs.zsh.shellAliases.Vi;

  systemd.user.services.zsh-history-backup.Install.WantedBy=["default.target"];
  systemd.user.services.zsh-history-backup.Service.ExecStart="${pkgs.copier}/bin/copier -from %h/${programs.zsh.history.path} -to %h/${programs.zsh.history.path}.bkp";
  systemd.user.services.zsh-history-backup.Service.Restart="always";
  systemd.user.services.zsh-history-backup.Unit.Description="Backup zsh history file on every write, restore on every delete";

  xdg.configFile."zsh/.zshrc.local".source = ../dotfiles/zsh/zshrc.local;
}
