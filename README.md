# Infrastructure
My NixOps network infrastructure.

Deployment is done using `nixops` with network defined in `default.nix` (which includes the machine deployment is made from).

- `nixops/*` contains declarations usable by `nixops`.
- `home/*` _should_ be usable by `home-manager`.
- `nixos/*` _should_ be usable by `nixos-rebuild`.
- `nixpkgs` contains `nixpkgs` config and overlays.
- `vendor` contains dependencies.
