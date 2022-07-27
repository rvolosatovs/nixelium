{...} @ inputs: let
  benefice = import ./benefice.nix inputs;
  drawbridge = import ./drawbridge.nix inputs;
  steward = import ./steward.nix inputs;
in
  benefice
  // drawbridge
  // steward
