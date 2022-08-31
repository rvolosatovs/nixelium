{...} @ inputs: {
  scripts = import ./scripts.nix inputs;
  systemd = import ./systemd.nix inputs;
}
