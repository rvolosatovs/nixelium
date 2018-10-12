# Infrastructure
My NixOps network infrastructure.

Deployment is done using `nixops`.
Currently, there only exists one network, declared at `nixops/networks/private`.

- `home` _should_ be usable by `home-manager`.
- `modules` contains generic Nix modules.
- `nixops` contains declarations usable by `nixops`.
- `nixos` _should_ be usable by `nixos-rebuild`.
- `nixpkgs` contains `nixpkgs` config and overlays.
- `resources` contains public definitions of various resources(see `modules/resources.nix`).
- `vendor` contains dependencies:
    - `pass` contains pass-store passwords.
    - `secrets` contains secret Nix definitions. The structure is identical to this repository.
