{ self, ... }:
let
  scripts = pkgs: _: {
    git-rebase-all = pkgs.writeShellScriptBin "git-rebase-all" ''
      set -e

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

    gh-merge-dependabot = pkgs.writeShellScriptBin "gh-merge-dependabot" ''
      set -euo pipefail

      merge_method=()
      repo=""
      for arg in "$@"; do
        case "$arg" in
          --merge | --rebase | --squash) merge_method=("$arg") ;;
          *) repo="$arg" ;;
        esac
      done

      repo="''${repo:-$(${pkgs.gh}/bin/gh repo view --json nameWithOwner -q .nameWithOwner)}"
      owner="''${repo%%/*}"
      name="''${repo#*/}"

      me="$(${pkgs.gh}/bin/gh api user --jq .login)"

      ${pkgs.gh}/bin/gh api graphql \
        -f owner="$owner" \
        -f name="$name" \
        -f query='
          query($owner: String!, $name: String!) {
            repository(owner: $owner, name: $name) {
              pullRequests(states: OPEN, first: 100) {
                nodes {
                  number
                  url
                  isInMergeQueue
                  author { login }
                  latestReviews(first: 100) {
                    nodes {
                      state
                      author { login }
                    }
                  }
                }
              }
            }
          }' |
        ${pkgs.jq}/bin/jq -r --arg me "$me" '
          .data.repository.pullRequests.nodes[]
          | select(.author.login == "dependabot")
          | select(.isInMergeQueue | not)
          | [
              .number,
              .url,
              any(.latestReviews.nodes[]; .author.login == $me and .state == "APPROVED")
            ]
          | @tsv' |
      while IFS=$'\t' read -r number url approved; do
        if [ "$approved" = "true" ]; then
          echo "PR #$number ($url) already approved, enabling auto-merge"
        else
          echo "Approving and auto-merging PR #$number ($url)"
          if ! ${pkgs.gh}/bin/gh pr review --repo "$repo" --approve "$number"; then
            echo "Skipping PR #$number: could not approve" >&2
          fi
        fi
        if ! ${pkgs.gh}/bin/gh pr merge --repo "$repo" --auto "''${merge_method[@]}" "$number"; then
          echo "Skipping PR #$number: could not enable auto-merge" >&2
        fi
      done
    '';
  };
in
final: prev: scripts final prev
