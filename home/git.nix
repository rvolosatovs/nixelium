{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    git-lfs
  ];
  home.sessionVariables.GIT_EDITOR = config.meta.programs.editor.executable.path;

  programs.git.aliases = {
    a = "apply --index";
    p = "format-patch --stdout";
    tree = "log --graph --pretty=format:'%C(auto)%h - %s [%an] (%C(blue)%ar)%C(auto)%d'";
    bigtree = "log --graph --decorate --pretty=format:'%C(auto)%d%n%h %s%+b%n(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n'";
    hist = "log --date=short --pretty=format:'%C(auto)%ad %h (%G?) %s [%an] %d'";
    xclean = "clean -xdf -e .envrc -e .direnv.* -e shell.nix -e default.nix -e vendor -e .vscode";
  };
  programs.git.enable = true;
  programs.git.extraConfig = ''
    [push]
    default = nothing
    gpgSign = if-asked
    [status]
    short = true
    branch = true
    submoduleSummary = true
    showUntrackedFiles = all
    [color]
    ui = true
    [diff]
    renames = copy
    [branch]
    autosetupmerge = false
    autosetuprebase = always
    [core]
    autocrlf = false
    safecrlf = false
    editor = ${config.meta.programs.editor.executable.path}
    excludesfile = ${builtins.toPath ./../dotfiles/git/gitignore}
    [merge]
    tool = nvimdiff
    conflictstyle = diff3
    [diff]
    tool = nvimdiff
    [mergetool "nvimdiff"]
    cmd = ${pkgs.neovim}/bin/nvim -d $LOCAL $BASE $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'
    [format]
    pretty = %C(auto)%h - %s%d%n%+b%+N(%G?) %an <%ae> (%C(blue)%ad%C(auto))%n
    [http]
    cookieFile = ~/.gitcookies
    [http "https://gopkg.in"]
    followRedirects = true
    [filter "lfs"]
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true
    [rerere]
    enabled = true
    [ghq]
    root = ~/src
    [ghq "https://go.thethings.network"]
    vcs = git
  '';
  programs.git.userName = config.meta.fullName;
  programs.git.userEmail = config.meta.email;
}
