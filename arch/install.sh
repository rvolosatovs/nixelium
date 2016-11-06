#!/usr/bin/env bash
HOSTNAME="nirvana"
USERNAME="rvolosatovs"

BOOT_PART="/dev/sdb1"
LUKS_PART="/dev/sdb2"

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

timedatectl set-ntp true

#echo "Chillax, this will take a while..."
#cryptsetup open --type plain $LUKS_PART container
#if ![ fdisk -l | grep "/dev/mapper/container" ];then
#    echo "Can't find /dev/mapper/container"
#    echo "exiting"
#fi
#dd if=/dev/zero of=/dev/mapper/container bs=1M
#cryptsetup luksClose container

cryptsetup luksFormat -v --key-size 512 --hash sha512 --use-random --verify-passphrase $LUKS_PART
cryptsetup luksOpen $LUKS_PART $LUKS_NAME

luksDev="/dev/mapper/$LUKS_NAME"

pvcreate $luksDev
vgcreate $VG_NAME $luksDev

lvcreate -L $SWAP_SIZE $VG_NAME -n $SWAP_NAME
mkswap -L $SWAP_NAME /dev/$VG_NAME/$SWAP_NAME

lvcreate -l 100%FREE $VG_NAME -n $BTRFS_NAME
mkfs.btrfs -L $BTRFS_NAME /dev/$VG_NAME/$BTRFS_NAME

mount -o $btrfsMountOpts $btrfsDev /mnt

for sub in $SUBVOLUMES; do
   path="/mnt/$sub"
   mkdir -pv `dirname $path`
   btrfs su create $path
done
umount /mnt

btrfsDev="/dev/$VG_NAME/$BTRFS_NAME"
swapDev="/dev/$VG_NAME/$SWAP_NAME"

mount -o $btrfsMountOpts,subvol=$ROOT_SUBVOL $btrfsDev /mnt
mkdir -pv /mnt/{home,boot,.snaphots}

mount $BOOT_PART /mnt/boot
mount -o $btrfsMountOpts,subvol=$HOME_SUBVOL $btrfsDev /mnt/home
swapon $swapDev

curl --create-dirs -fLo /etc/pacman.d/mirrorlist $configAddr/etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel multilib-devel btrfs-progs dosfsutils rfkill reflector pciutils lm_sensors acpi cower zsh grml-zsh-config git docker openjdk go julia python nodejs neovim keychain pass gnupg bspwm sxhkd feh imv mpv rofi termite chromium firefox thunderbird xscreensaver xorg-xsetroot xorg-xdpyinfo xorg-xrandr xorg-xlsfonts xorg-xset intel-ucode

genfstab -p /mnt >> /mnt/etc/fstab

curl --create-dirs -fLo /mnt/etc/mkinitcpio.conf $configAddr/etc/mkinitcpio.conf

echo $HOSTNAME > /mnt/etc/hostname
echo "127.0.1.1	$HOSTNAME.localdomain	$HOSTNAME" >> /mnt/etc/hosts

curl --create-dirs -fLo /mnt/etc/locale.gen $configAddr/etc/locale.gen 
curl --create-dirs -fLo /mnt/etc/locale.conf $configAddr/etc/locale.conf 

curl --create-dirs -fLo /mnt/etc/vconsole.conf $configAddr/etc/vconsole.conf 

curl --create-dirs -fLo /mnt/tmp/install/install-chroot.sh $configAddr/install-chroot.sh 
#arch-chroot /mnt "/bin/bash /tmp/install/install-chroot.sh $USERNAME"

curl --create-dirs -fLo /mnt/boot/loader/loader.conf $configAddr/boot/loader.conf 
curl --create-dirs -fLo /mnt/boot/loader/entries/arch.conf $configAddr/boot/entries/arch.conf 
