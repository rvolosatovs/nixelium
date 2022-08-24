{...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://enarx.cachix.org"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "enarx.cachix.org-1:Izq345bPMThAWUW830X3uoGTTBjXW7ltGlfTBErgm4w="
  ];
  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.gc.automatic = true;
  nix.optimise.automatic = true;
  nix.package = pkgs.nixUnstable;
  nix.requireSignedBinaryCaches = true;
  nix.settings.auto-optimise-store = true;
  nix.settings.allowed-users = with config.users; [
    "@${groups.wheel.name}"
    users.root.name
  ];
  nix.settings.trusted-users = with config.users; [
    users.root.name
  ];
}
