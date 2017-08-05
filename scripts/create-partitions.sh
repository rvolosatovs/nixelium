#!/usr/bin/env bash
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


subvolumes=( $rootSub $homeSub $snapSub "@/srv" "@/var/tmp" "@/nix/store" )

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
    cryptsetup open --type plain $luksPart container
    if ! [ `fdisk -l | grep "/dev/mapper/container"` ];then
        echo "Can't find /dev/mapper/container"
        exit 1
    fi
    dd if=/dev/zero of=/dev/mapper/container bs=1M
    cryptsetup luksClose container
fi

echo "Encrypting $luksPart..."
cryptsetup luksFormat -v --key-size 512 --hash sha512 --use-random --verify-passphrase $luksPart || exit 1
cryptsetup luksOpen $luksPart $luksName || exit 1

luksDev="/dev/mapper/$luksName"
echo "Setting up LVM on $luksDev..."
pvcreate $luksDev || exit 1
vgcreate $vgName $luksDev || exit 1

swapDev="/dev/$vgName/$swapName"
echo "Creating swap on $swapDev..."
lvcreate -L $swapSize $vgName -n $swapName || exit 1
mkswap -L $swapName $swapDev || exit 1

btrfsDev="/dev/$vgName/$btrfsName"
echo "Creating btrfs on $btrfsDev..."
lvcreate -l 100%FREE $vgName -n $btrfsName || exit 1
mkfs.btrfs -L $btrfsName $btrfsDev || exit 1


mount -o $btrfsMountOpts $btrfsDev /mnt || exit 1
for sub in ${subvolumes[@]}; do
   path="/mnt/$sub"
   mkdir -pv `dirname $path` || exit 1
   btrfs su create $path || exit 1
done
umount /mnt

echo "Creating vfat on $bootPart..."
mkfs.vfat -F 32 -n boot $bootPart || exit 1

mount -o $btrfsMountOpts,subvol=$rootSub $btrfsDev /mnt || exit 1
mkdir -pv /mnt/{home,boot,.snaphots} || exit 1
mount $bootPart /mnt/boot || exit 1
mount -o $btrfsMountOpts,subvol=$homeSub $btrfsDev /mnt/home || exit 1
swapon $swapDev || exit 1
