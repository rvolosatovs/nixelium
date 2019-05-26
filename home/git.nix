{ config, pkgs, ... }:

let
  gitignore = pkgs.writeText "gitignore" ''
    *.aux
    *.dvi
    *.ear
    *.jar
    *.log
    *.out
    *.pdf
    *.rar
    *.sql
    *.sqlite
    *.tar.gz
    *.test
    *.war
    *.zip
    *~
    ._*
    .direnv*
    .DS_Store
    .DS_Store?
    .envrc*
    .Spotlight-V100
    .Trashes
    .vscode
    ehthumbs.db
    shell.nix
    tags
    Thumbs.db
    token
  '';

  extraConfig = ''
    [branch]
      autosetupmerge = false
      autosetuprebase = always
    [color]
      ui = true
    [core]
      autocrlf = false
      editor = ${config.resources.programs.editor.executable.path}
      excludesfile = ${gitignore}
      safecrlf = false
    [diff]
      colorMoved = zebra
      renames = copy
      tool = nvimdiff
    [fetch]
      prune = true
    [filter "lfs"]
      clean = git-lfs clean -- %f
      process = git-lfs filter-process
      required = true
      smudge = git-lfs smudge -- %f
    [format]
      pretty = %C(auto)%h - %s%d%n%+b%+N(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n
    [ghq]
      root = ~/src
    [ghq "https://go.thethings.network"]
      vcs = git
    [http]
      cookieFile = ~/.gitcookies
    [http "https://gopkg.in"]
      followRedirects = true
    [merge]
      conflictstyle = diff3
      tool = nvimdiff
    [mergetool "nvimdiff"]
      cmd = ${pkgs.neovim}/bin/nvim -c "Gvdiff" $MERGED
    [push]
      default = nothing
      gpgSign = if-asked
    [rebase]
      autosquash = true
    [rerere]
      enabled = true
    [status]
      branch = true
      short = true
      showUntrackedFiles = all
      submoduleSummary = true
    [url "ssh://git@github.com/TheThingsNetwork"]
      insteadOf = https://github.com/TheThingsNetwork
    [url "ssh://git@github.com/TheThingsIndustries"]
      insteadOf = https://github.com/TheThingsIndustries
  '';
in
  {
    home.packages = with pkgs; [
      git-lfs
    ];
    home.sessionVariables.GIT_EDITOR = config.resources.programs.editor.executable.path;

    programs.git.aliases.a = "apply --index";
    programs.git.aliases.p = "format-patch --stdout";
    programs.git.aliases.tree = "log --graph --pretty=format:'%C(auto)%h - %s [%an] (%C(blue)%ar)%C(auto)%d'";
    programs.git.aliases.bigtree = "log --graph --decorate --pretty=format:'%C(auto)%d%n%h %s%+b%n(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n'";
    programs.git.aliases.hist = "log --date=short --pretty=format:'%C(auto)%ad %h (%G?) %s [%an] %d'";
    programs.git.aliases.xclean = "clean -xdf -e .envrc -e .direnv.* -e shell.nix -e default.nix -e vendor -e .vscode";

    programs.git.enable = true;
    programs.git.extraConfig = extraConfig;
    programs.git.userName = config.resources.fullName;
    programs.git.userEmail = config.resources.email;

    programs.zsh.shellAliases.ga="git add .";
    programs.zsh.shellAliases.gaf="git add";
    programs.zsh.shellAliases.gb="git branch";
    programs.zsh.shellAliases.gB="git rebase";
    programs.zsh.shellAliases.gBC="git add . && git rebase --continue";
    programs.zsh.shellAliases.gBc="git rebase --continue";
    programs.zsh.shellAliases.gbi="git branch -lvv";
    programs.zsh.shellAliases.gC="git commit -am";
    programs.zsh.shellAliases.gc="git commit";
    programs.zsh.shellAliases.gca="git commit --amend";
    programs.zsh.shellAliases.gcm="git commit -m";
    programs.zsh.shellAliases.gd="git diff --word-diff=color";
    programs.zsh.shellAliases.gdc="git diff --word-diff=color --cached";
    programs.zsh.shellAliases.gf="git fetch --all --prune";
    programs.zsh.shellAliases.gH1="git hist --shortstat --oneline";
    programs.zsh.shellAliases.gh1="git hist --oneline";
    programs.zsh.shellAliases.gH="git hist --shortstat";
    programs.zsh.shellAliases.gh="git hist";
    programs.zsh.shellAliases.gHH="git hist --shortstat --all";
    programs.zsh.shellAliases.ghh="git hist --all";
    programs.zsh.shellAliases.gL1="git log --word-diff=color --patch-with-stat --oneline";
    programs.zsh.shellAliases.gl1="git log --stat --date=short --oneline";
    programs.zsh.shellAliases.gl="git log --stat --date=short";
    programs.zsh.shellAliases.gL="git log --word-diff=color --patch-with-stat";
    programs.zsh.shellAliases.gLL="git log --word-diff=color --patch-with-stat --all";
    programs.zsh.shellAliases.gll="git log --stat --date=short --all";
    programs.zsh.shellAliases.gm="git cherry-pick";
    programs.zsh.shellAliases.gM="git merge";
    programs.zsh.shellAliases.gn="git checkout";
    programs.zsh.shellAliases.gnb="git checkout -b";
    programs.zsh.shellAliases.gno="git checkout --orphan";
    programs.zsh.shellAliases.gp="git pull";
    programs.zsh.shellAliases.gP="git push";
    programs.zsh.shellAliases.gpp="git pull --prune";
    programs.zsh.shellAliases.gPp="git push --prune";
    programs.zsh.shellAliases.gr="git remote";
    programs.zsh.shellAliases.gR="git reset";
    programs.zsh.shellAliases.gRh="git reset --hard";
    programs.zsh.shellAliases.grl="git reflog";
    programs.zsh.shellAliases.gS="git show --word-diff=color";
    programs.zsh.shellAliases.gs="git status";
    programs.zsh.shellAliases.gsl="git shortlog";
    programs.zsh.shellAliases.gT="git bigtree --summary --shortstat --dirstat";
    programs.zsh.shellAliases.gt="git tree";
    programs.zsh.shellAliases.gTT="git bigtree --summary --shortstat --dirstat --all";
    programs.zsh.shellAliases.gtt="git tree --all";
    programs.zsh.shellAliases.gy="git stash";
    programs.zsh.shellAliases.gyd="git stash drop";
    programs.zsh.shellAliases.gyp="git stash pop";
  }
