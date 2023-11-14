{self, ...}: let
  scripts = pkgs: _: {
    git-rebase-all = pkgs.writeShellScriptBin "git-rebase-all" ''
      set -xe

      base=''${1:-main}
      for b in $(${pkgs.git}/bin/git for-each-ref --no-contains "''${base}" refs/heads --format '%(refname:lstrip=2)'); do
          ${pkgs.git}/bin/git checkout -q "''${b}"
          if ! ${pkgs.git}/bin/git rebase -q "''${base}" &> /dev/null; then
              echo "''${b} can not be rebased automatically"
              ${pkgs.git}/bin/git rebase --abort
          fi
      done

      ${pkgs.git}/bin/git checkout -q "''${base}" && ${pkgs.git}/bin/git branch --merged | grep -v '\*' | ${pkgs.findutils}/bin/xargs -r ${pkgs.git}/bin/git branch -d
    '';
  };
in
  final: prev: scripts final prev
