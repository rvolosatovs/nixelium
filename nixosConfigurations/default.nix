{...} @ inputs: let
  infra = import ./infra.nix inputs;
  services = import ./services inputs;
in
  infra
  // services
