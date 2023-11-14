inputs @ {...}: let
  cloud-init = import ./cloud-init.nix inputs;
  install-iso = import ./install-iso.nix inputs;
  nixelium = import ./nixelium.nix inputs;
  phosphorus = import ./phosphorus.nix inputs;
in {
  inherit
    cloud-init
    install-iso
    nixelium
    phosphorus
    ;
  default = nixelium;
}
