inputs @ {nixlib, ...}: rec {
  service = import ./service.nix inputs;
  tooling = import ./tooling inputs;

  default = nixlib.lib.composeManyExtensions [
    service
    tooling
  ];
}
