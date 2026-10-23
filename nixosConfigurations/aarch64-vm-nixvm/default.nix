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
      {
        config,
        pkgs,
        ...
      }:
      {
        imports = [ self.nixosModules.default ];

        networking.hostName = "linux-aarch64-vm";

        nixelium.profile.dev.enable = true;
        nixelium.profile.vm.enable = true;

        home-manager.users.owner.nixelium.profile.unrestricted-ai.enable = true;

        nixvm.guest.rootSize = "256G";

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
        fileSystems."/nix/.rw-store".options = [ "size=24G" ];

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

        # At shutdown, swapoff must page every swapped-out tmpfs page back
        # into RAM; with the writable store grown past RAM that OOMs PID 1
        # and panics ("System is deadlocked on memory"). Deleting the
        # store's upper layer first, then dropping the overlay's cached
        # inodes that still pin the deleted files, frees its swap without
        # paging it in.
        # The system closure lives in the read-only lower layer, so nothing
        # still running needs it, and the tmpfs is discarded anyway.
        systemd.services.nix-rw-store-wipe = {
          description = "Wipe writable Nix store layer before swapoff";
          unitConfig.DefaultDependencies = false;
          after = [ "swap.target" ];
          before = [
            "sysinit.target"
            "shutdown.target"
          ];
          conflicts = [ "shutdown.target" ];
          wantedBy = [ "sysinit.target" ];
          restartIfChanged = false;
          unitConfig.X-StopOnRemoval = false;
          unitConfig.IgnoreOnIsolate = true;
          unitConfig.RefuseManualStop = true;
          serviceConfig.Type = "oneshot";
          serviceConfig.RemainAfterExit = true;
          serviceConfig.ExecStop = [
            "-${pkgs.findutils}/bin/find ${
              config.fileSystems."/nix/store".overlay.upperdir
            } -mindepth 1 -delete"
            "${pkgs.procps}/bin/sysctl -w vm.drop_caches=2"
          ];
        };

        services.getty.autologinUser = config.users.users.owner.name;

        system.image.id = "linux-aarch64-vm";
        system.image.version = "1";
        system.stateVersion = "24.11";
      }
    )
  ];
}
