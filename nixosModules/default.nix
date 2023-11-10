inputs @ {...}: let
  nixelium = import ./nixelium.nix inputs;
in {
  inherit
    nixelium
    ;
  default = nixelium;
}
