inputs @ {nixlib, ...}: rec {
  images = import ./images.nix inputs;
  service = import ./service.nix inputs;
  tooling = import ./tooling inputs;

  default = nixlib.lib.composeManyExtensions [
    images
    service
    tooling
  ];
}
