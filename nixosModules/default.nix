inputs @ {...}: {
  benefice = import ./benefice.nix inputs;
  common = import ./common.nix inputs;
  cloudflared = import ./cloudflared.nix inputs;
  drawbridge = import ./drawbridge.nix inputs;
  providers = import ./providers.nix inputs;
  service = import ./service.nix inputs;
  shells = import ./shells.nix inputs;
  steward = import ./steward.nix inputs;
  monitoring = import ./monitoring.nix inputs;
  users = import ./users.nix inputs;
}
