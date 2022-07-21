inputs @ {nixlib, ...}: rec {
  service = import ./service.nix inputs;
  tooling = import ./tooling.nix inputs;

  default = nixlib.lib.composeExtensions service tooling;
}
