#!/usr/bin/env bash
HOSTNAME="nirvana"
USERNAME="rvolosatovs"

BOOT_PART="/dev/sdc1"
LUKS_PART="/dev/sdc2"

LUKS_NAME="luksroot"
VG_NAME="partitions"
BTRFS_NAME="butter"
SWAP_NAME="swap"
SWAP_SIZE="16G"

ROOT_SUBVOL="@"
HOME_SUBVOL="@home"
SNAPSHOT_SUBVOL="@snapshots"

btrfsMountOpts="noatime,ssd,compress=lzo,discard"

DOTFILE_REPO="rvolosatovs/dotfiles"
DOTFILE_BRANCH="master"

configAddr="https://raw.githubusercontent.com/$DOTFILE_REPO/$DOTFILE_BRANCH/arch"

SUBVOLUMES=( $ROOT_SUBVOL $HOME_SUBVOL $SNAPSHOT_SUBVOL "@/srv" "@/var/tmp" "@/var/abs" "@/var/cache/pacman/pkg" )

rm -rf /mnt
umount /mnt/boot
umount /mnt
swapoff -a


timedatectl set-ntp true

#echo "Chillax, this will take a while..."
#cryptsetup open --type plain $LUKS_PART container
#if ![ fdisk -l | grep "/dev/mapper/container" ];then
#    echo "Can't find /dev/mapper/container"
#    echo "exiting"
#fi
#dd if=/dev/zero of=/dev/mapper/container bs=1M
#cryptsetup luksClose container

cryptsetup luksFormat -v --key-size 512 --hash sha512 --use-random --verify-passphrase $LUKS_PART || exit 1
cryptsetup luksOpen $LUKS_PART $LUKS_NAME || exit 1

luksDev="/dev/mapper/$LUKS_NAME"

pvcreate $luksDev || exit 1
vgcreate $VG_NAME $luksDev || exit 1

lvcreate -L $SWAP_SIZE $VG_NAME -n $SWAP_NAME || exit 1
mkswap -L $SWAP_NAME /dev/$VG_NAME/$SWAP_NAME || exit 1

lvcreate -l 100%FREE $VG_NAME -n $BTRFS_NAME || exit 1
mkfs.btrfs -L $BTRFS_NAME /dev/$VG_NAME/$BTRFS_NAME || exit 1

btrfsDev="/dev/$VG_NAME/$BTRFS_NAME"
swapDev="/dev/$VG_NAME/$SWAP_NAME"

mount -o $btrfsMountOpts $btrfsDev /mnt || exit 1

for sub in $SUBVOLUMES; do
   path="/mnt/$sub"
   mkdir -pv `dirname $path` || exit 1
   btrfs su create $path || exit 1
done
umount /mnt

mount -o $btrfsMountOpts,subvol=$ROOT_SUBVOL $btrfsDev /mnt || exit 1
mkdir -pv /mnt/{home,boot,.snaphots} || exit 1

mount $BOOT_PART /mnt/boot || exit 1
mount -o $btrfsMountOpts,subvol=$HOME_SUBVOL $btrfsDev /mnt/home || exit 1
swapon $swapDev || exit 1

curl --create-dirs -fLo /etc/pacman.d/mirrorlist $configAddr/etc/pacman.d/mirrorlist || exit 1

pacstrap /mnt base base-devel btrfs-progs dosfsutils rfkill reflector pciutils lm_sensors acpi zsh grml-zsh-config git docker go julia python nodejs neovim keychain pass gnupg bspwm sxhkd feh imv mpv rofi termite chromium firefox thunderbird xscreensaver xorg-xsetroot xorg-xdpyinfo xorg-xrandr xorg-xlsfonts xorg-xset intel-ucode || exit 1

genfstab -p /mnt >> /mnt/etc/fstab || exit 1

curl --create-dirs -fLo /mnt/etc/mkinitcpio.conf $configAddr/etc/mkinitcpio.conf || exit 1

echo $HOSTNAME > /mnt/etc/hostname || exit 1
echo "127.0.1.1	$HOSTNAME.localdomain	$HOSTNAME" >> /mnt/etc/hosts || exit 1

curl --create-dirs -fLo /mnt/etc/locale.gen $configAddr/etc/locale.gen  || exit 1
curl --create-dirs -fLo /mnt/etc/locale.conf $configAddr/etc/locale.conf  || exit 1

curl --create-dirs -fLo /mnt/etc/vconsole.conf $configAddr/etc/vconsole.conf  || exit 1

curl --create-dirs -fLo /mnt/tmp/install/install-chroot.sh $configAddr/install-chroot.sh  || exit 1
#arch-chroot /mnt "/bin/bash /tmp/install/install-chroot.sh $USERNAME"

curl --create-dirs -fLo /mnt/boot/loader/loader.conf $configAddr/boot/loader.conf  || exit 1
curl --create-dirs -fLo /mnt/boot/loader/entries/arch.conf $configAddr/boot/entries/arch.conf  || exit 1
