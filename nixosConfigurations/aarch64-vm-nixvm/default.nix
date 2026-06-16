{
  self,
  flake-utils,
  nixpkgs-nixos,
  nixvm,
  ...
}:
with flake-utils.lib.system;
nixpkgs-nixos.lib.nixosSystem {
  system = aarch64-linux;
  modules = [
    nixvm.nixosModules.guest
    (
      { config, lib, ... }:
      {
        imports = [ self.nixosModules.default ];

        networking.hostName = "linux-aarch64-vm";

        nixelium.profile.dev.enable = true;
        nixelium.profile.vm.enable = true;

        home-manager.users.owner.nixelium.profile.unrestricted-ai.enable = true;

        nixvm.guest.rootSize = "128G";

        # Raise the /nix/store overlay's writable-tmpfs cap and back it with
        # swap. nixvm.nixosModules.guest mounts the overlay's upper/work on a
        # tmpfs (`/nix/.rw-store`) that defaults to 50% of guest RAM (~4G) —
        # too small for cross-compile build trees, which OOM the dev shell
        # with "No space left on device". Bumping `size=` and adding a
        # swapfile lets the writable store grow well past RAM, spilling cold
        # build artifacts to disk via swap while hot pages stay resident.
        #
        # Deliberately kept a tmpfs rather than relocated onto the root ext4:
        # a tmpfs is wiped on every boot, so the writable store starts clean
        # each launch under BOTH `nixvm run` (per-launch ephemeral image) and
        # `nixvm load` (which preserves on-disk /var,/etc,/home across
        # resumes). A disk-backed upper would instead accumulate guest-built
        # paths across every `nixvm load` with no way to reclaim them:
        # `nix.gc` cannot run on this overlay (deleting a path on the virtiofs
        # read-only lower fails with fchmodat2/EOPNOTSUPP), as nixvm's guest
        # module asserts. The boot-time tmpfs wipe is the only reliable "GC".
        #
        # size= must stay below RAM + swap or a full store OOMs instead of
        # erroring; 24G cap vs 32G swap (+~8G RAM) leaves headroom.
        fileSystems."/nix/.rw-store".options = lib.mkForce [
          "mode=0755"
          "size=24G"
        ];

        # Swap on the root partition: backs the enlarged writable-store tmpfs
        # and gives memory-hungry linkers/rustc headroom during parallel
        # cross-compiles (guest RAM is modest). Created on first boot; under
        # `nixvm load` it persists in the saved image.
        swapDevices = [
          {
            device = "/swapfile";
            size = 32 * 1024; # MiB
          }
        ];

        services.getty.autologinUser = config.users.users.owner.name;

        system.image.id = "linux-aarch64-vm";
        system.image.version = "1";
        system.stateVersion = "24.11";
      }
    )
  ];
}
