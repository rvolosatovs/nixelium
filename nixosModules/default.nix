inputs @ {...}: rec {
  common = import ./common.nix inputs;
  equinix = import ./providers/equinix;
  users = import ./users.nix inputs;
}
