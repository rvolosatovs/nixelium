{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
  mypkgs = import <mypkgs> {};
  vars = import ../../.dotfiles/nixos/var/variables.nix { inherit pkgs; };

  rubyVersion = "2.4.0";
in

rec {
  imports = [
    ./gtk.nix
  ];

  xdg.enable = true;
  xdg.configHome = "${vars.homeDir}/.config";
  xdg.cacheHome = "${config.home.homeDirectory}/.local/cache";
  xdg.dataHome = "${home.homeDirectory}/.local/share";

  home.packages = with pkgs; [
    htop
    curl
    git
    docker_compose
    pv
    fzf
    ripgrep

    zsh-syntax-highlighting 
  ];

  home.sessionVariables.EMAIL="${vars.email}";
  home.sessionVariables.EDITOR="${vars.editor}";
  home.sessionVariables.VISUAL="${vars.editor}";
  home.sessionVariables.BROWSER="${vars.browser}";
  home.sessionVariables.PAGER="${vars.pager}";

  #home.sessionVariables.XDG_CONFIG_HOME="${xdg.configHome}";
  #home.sessionVariables.XDG_CACHE_HOME="${xdg.cacheHome}";
  #home.sessionVariables.XDG_DATA_HOME="${xdg.dataHome}";

  home.sessionVariables.PASSWORD_STORE_DIR="${home.homeDirectory}/.local/pass";

  home.sessionVariables.GOPATH="${home.homeDirectory}";
  home.sessionVariables.GOBIN="${home.homeDirectory}/.local/bin.go";
  home.sessionVariables.PATH="${home.homeDirectory}/.local/bin:${home.sessionVariables.GOBIN}:${home.homeDirectory}/.gem/ruby/${rubyVersion}/bin:${xdg.dataHome}/npm/bin:\${PATH}";

  home.sessionVariables.WINEPREFIX="${xdg.dataHome}/wine";

  home.sessionVariables.TMUX_TMPDIR="\${XDG_RUNTIME_DIR}/tmux";

  home.sessionVariables.LESSHISTFILE="${xdg.cacheHome}/less/history";
  home.sessionVariables.__GL_SHADER_DISK_CACHE_PATH="${xdg.cacheHome}/nv";
  home.sessionVariables.CUDA_CACHE_PATH="${xdg.cacheHome}/nv";
  home.sessionVariables.PYTHON_EGG_CACHE="${xdg.cacheHome}/python-eggs";

  home.sessionVariables.GIMP2_DIRECTORY="${xdg.configHome}/gimp";
  home.sessionVariables.INPUTRC="${xdg.configHome}/readline/inputrc";
  home.sessionVariables.ELINKS_CONFDIR="${xdg.configHome}/elinks";
  #GNUPGHOME="${xdg.configHome}/gnupg";
  #GTK2_RC_FILES="${xdg.configHome}/gtk-2.0/gtkrc";

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 180000;
    defaultCacheTtlSsh = 180000;
    writeEnvFile = "${xdg.cacheHome}/gpg-agent-info";
    enableSshSupport = true;
    disableScDaemon = true;
    noGrab = true;
  };

  home.sessionVariables.ZPLUG_HOME= "${xdg.configHome}/zsh/zplug";
  home.sessionVariableSetter = "zsh";

  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.dotDir = "${xdg.configHome}/zsh";
  programs.zsh.history.path = "${programs.zsh.dotDir}/.zhistory";
  programs.zsh.history.ignoreDups = true;
  programs.zsh.history.share = true;
  programs.zsh.initExtra = ''
     source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
     HISTFILE="${xdg.configHome}/zsh/.zhistory"
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
