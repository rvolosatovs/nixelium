inputs @ {...}: {
  benefice = import ./benefice.nix inputs;
  cloudflared = import ./cloudflared.nix inputs;
  common = import ./common.nix inputs;
  drawbridge = import ./drawbridge.nix inputs;
  monitoring = import ./monitoring.nix inputs;
  providers = import ./providers.nix inputs;
  service = import ./service.nix inputs;
  sev = import ./sev.nix inputs;
  sgx = import ./sgx.nix inputs;
  shells = import ./shells.nix inputs;
  steward = import ./steward.nix inputs;
  users = import ./users.nix inputs;
}
