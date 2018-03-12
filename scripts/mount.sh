#!/usr/bin/env bash
set -xe

disk="/dev/sda"

luksName="luksroot"
vgName="partitions"
btrfsName="butter"
swapName="swap"
swapSize="8G"

btrfsMountOpts="autodefrag,compress=lzo"

bootPart="${disk}1"
luksPart="${disk}2"

luksDev="/dev/mapper/$luksName"
btrfsDev="/dev/$vgName/$btrfsName"
swapDev="/dev/$vgName/$swapName"

mount -o $btrfsMountOpts,subvol=$rootSub $btrfsDev /mnt
mkdir -pv /mnt/{home,boot,.snaphots}
mount $bootPart /mnt/boot
mount -o $btrfsMountOpts,subvol=$homeSub $btrfsDev /mnt/home
swapon $swapDev
