#!/usr/bin/env bash
set -xe

disk="/dev/sda"

luksName="luksroot"
vgName="partitions"
btrfsName="butter"
swapName="swap"
swapSize="16G"

rootSub="@"
homeSub="@home"
snapSub="@snapshots"

btrfsMountOpts="autodefrag,noatime,ssd,compress=lzo,discard"

while getopts "d:v:b:s:S:c" opt; do
    case $opt in
        d)
            disk=$OPTARG 
            ;;
        v)
            vgName=$OPTARG 
            ;;
        b)
            btrfsName=$OPTARG 
            ;;
        s)
            swapName=$OPTARG 
            ;;
        S)
            swapSize=$OPTARG 
            ;;
        c)
            clean=1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

subvolumes=( "$rootSub" "$homeSub" "$snapSub" "@/nix/store" )

bootPart="${disk}1"
luksPart="${disk}2"


if [ `mount | grep "/mnt"` ]; then
    rm -rf /mnt
    umount /mnt/boot
    umount /mnt
    swapoff -a
    mkdir -p /mnt
fi

if [ $clean ];then
    echo "Chillax, this will take a while..."
    cat /dev/random | head -1 | base64 | cryptsetup open --type plain $luksPart container
    cat /dev/zero > /dev/mapper/container
    cryptsetup luksClose container
fi

echo "Encrypting $luksPart..."
cryptsetup luksFormat -v --key-size 512 --use-random --verify-passphrase $luksPart
cryptsetup luksOpen $luksPart $luksName

luksDev="/dev/mapper/$luksName"
echo "Setting up LVM on $luksDev..."
pvcreate $luksDev
vgcreate $vgName $luksDev

swapDev="/dev/$vgName/$swapName"
echo "Creating swap on $swapDev..."
lvcreate -L $swapSize $vgName -n $swapName
mkswap -L $swapName $swapDev

btrfsDev="/dev/$vgName/$btrfsName"
echo "Creating btrfs on $btrfsDev..."
lvcreate -l 100%FREE $vgName -n $btrfsName
mkfs.btrfs -L $btrfsName $btrfsDev

mount -o $btrfsMountOpts $btrfsDev /mnt
for sub in ${subvolumes[@]}; do
   path="/mnt/$sub"
   mkdir -pv `dirname $path`
   btrfs su create $path
done
umount /mnt

echo "Creating vfat on $bootPart..."
mkfs.vfat -F 32 -n boot $bootPart
#mkfs.ext4 -L boot $bootPart 

mount -o $btrfsMountOpts,subvol=$rootSub $btrfsDev /mnt
mkdir -pv /mnt/{home,boot,.snaphots}
mount $bootPart /mnt/boot
mount -o $btrfsMountOpts,subvol=$homeSub $btrfsDev /mnt/home
swapon $swapDev
