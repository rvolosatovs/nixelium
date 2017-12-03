{ config, pkgs, xdg, ... }:

rec {
  #home.sessionVariables.ZPLUG_HOME = "${xdg.configHome}/zsh/zplug";
  home.packages = with pkgs; [ zsh-syntax-highlighting ];

  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.dotDir = ".config/zsh";
  programs.zsh.history.path = ".config/zsh/.zhistory";
  programs.zsh.history.ignoreDups = true;
  programs.zsh.history.share = true;
  programs.zsh.initExtra = ''
     # Workaround grml setting HISTFILE
     oldHist="$HISTFILE"
     source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
     ! [ -z $oldHist ] && export HISTFILE="$oldHist"
     unset oldHist

     bindkey -v
     source "`${pkgs.fzf}/bin/fzf-share`/completion.zsh"
     source "`${pkgs.fzf}/bin/fzf-share`/key-bindings.zsh"

     CITY=''${CITY:-"Eindhoven"}
     { curl -s wttr.in/''${CITY} 2>/dev/null | head -7 } &|

     source ${xdg.dataHome}/base16/scripts/base16-tomorrow-night.sh
     source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

     eval "$(direnv hook zsh)"

     nixify() {
       if [ ! -e ./.envrc ]; then
         echo "use nix" > .envrc
         direnv allow
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
         zsh
       ];
     }
     EOF
         ''${EDITOR:-vim} ''${nixfile}
       fi
     }
  '';
  programs.zsh.shellAliases.dh="dirs -v";
  programs.zsh.shellAliases.vi="nvim";
  programs.zsh.shellAliases.vim="nvim";
  programs.zsh.shellAliases.Vi="sudoedit";
  programs.zsh.shellAliases.Vim="sudoedit";
  programs.zsh.shellAliases.ni="nix-env -i";
  programs.zsh.shellAliases.ne="nix-env -e";
  programs.zsh.shellAliases.nu="nix-env -u";
  programs.zsh.shellAliases.ns="nox";
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
  programs.zsh.shellAliases.gf="git fetch";
  programs.zsh.shellAliases.gfp="git fetch --prune";
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
}
