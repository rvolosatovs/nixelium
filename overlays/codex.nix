_: final: prev:
let
  # `codex` that marks the project it is launched in as trusted, skipping the
  # trust prompt that can't be persisted anyway because ~/.codex/config.toml is
  # a read-only store symlink.
  codex = final.writeShellScript "codex" ''
    root=$(${final.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd -P)
    exec ${final.codex}/bin/codex -c "projects={'$root'={trust_level='trusted'}}" "$@"
  '';
in
{
  codex-trusted = final.symlinkJoin {
    name = "codex-trusted-${final.codex.version}";
    inherit (final.codex) meta version;
    paths = [ final.codex ];
    postBuild = ''
      ln -sf ${codex} $out/bin/codex
    '';
  };
}
