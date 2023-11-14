{self, ...}: let
  install = pkgs: _:
    with pkgs.lib; let
      mkPartitionLaptop = config: disk: let
        boot = "${disk}p1";
        root = "${disk}p2";

        mountOptions = p: concatStringsSep "," config.fileSystems.${p}.options;
      in
        assert root == config.boot.initrd.luks.devices.luksroot.device;
          pkgs.writeShellScriptBin "partition-${config.networking.hostName}" ''
            set -xe

            parted -s '${disk}' -- mklabel gpt
            parted -s '${disk}' -- mkpart ESP 1MiB 2GiB
            parted -s '${disk}' -- set 1 boot on
            parted -s '${disk}' -- mkpart luksroot 2GiB 100%

            mkfs.vfat -F 32 -n boot '${boot}'
            mkdir -pv /mnt/boot
            mount '${boot}' /mnt/boot
            umount /mnt/boot

            cryptsetup luksFormat '${root}'
            cryptsetup luksOpen '${root}' luksroot

            pvcreate /dev/mapper/luksroot
            vgcreate partitions /dev/mapper/luksroot

            let swap=$(free -b | grep 'Mem' | tr -s '[:space:]' | cut -d ' ' -f 2)*2
            lvcreate -L ''${swap}b partitions -n swap
            mkswap -L swap /dev/partitions/swap
            swapon /dev/partitions/swap

            lvcreate -l 100%FREE partitions -n butter
            mkfs.btrfs -L butter /dev/partitions/butter

            mkdir -pv /butter
            mount /dev/partitions/butter /butter

            btrfs su create '/butter/@'
            btrfs su create '/butter/@-snapshots'

            btrfs su create '/butter/@home'
            btrfs su create '/butter/@home-snapshots'

            umount /butter

            mount -o '${mountOptions "/"}' /dev/partitions/butter /mnt

            mkdir -pv /mnt/home
            mount -o '${mountOptions "/home"}' /dev/partitions/butter /mnt/home

            mkdir -pv /mnt/boot
            mount '${boot}' /mnt/boot
          '';
    in {
      partition-osmium = mkPartitionLaptop self.nixosConfigurations.osmium.config "/dev/nvme0n1";
    };
in
  final: prev: install final prev
