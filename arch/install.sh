#!/usr/bin/env bash
disk="/dev/sdb"

hostname="atom"
username="rvolosatovs"

luksName="luksroot"
vgName="partitions"
btrfsName="butter"
swapName="swap"
swapSize="16G"

rootSub="@"
homeSub="@home"
snapSub="@snapshots"

btrfsMountOpts="autodefrag,noatime,ssd,compress=lzo,discard"

dotfileRepo="rvolosatovs/dotfiles"
dotfileBranch="master"

libvaDriver="intel"

while getopts "d:h:u:v:b:s:l:r:b:S:" opt; do
    case $opt in
        d)
            disk=$OPTARG 
            ;;
        V)
            libvaDriver=$OPTARG 
            ;;
        h)
            hostname=$OPTARG 
            ;;
        u)
            username=$OPTARG 
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
        r)
            dotfileRepo=$OPTARG 
            ;;
        B)
            dotfileRepo=$OPTARG 
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


subvolumes=( $rootSub $homeSub $snapSub "@/srv" "@/var/tmp" "@/var/abs" "@/var/cache/pacman/pkg" )

bootPart="${disk}1"
luksPart="${disk}2"

configAddr="https://raw.githubusercontent.com/$dotfileRepo/$dotfileBranch/arch"

timedatectl set-ntp true || exit 1

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
echo "Creating btrfs on $swapDev..."
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

curl -# --create-dirs -fLo /mnt/etc/mkinitcpio.conf $configAddr/etc/mkinitcpio.conf || echo "mkinitcpio.conf not found"

curl -# --create-dirs -fLo /etc/pacman.d/mirrorlist $configAddr/etc/pacman.d/mirrorlist || exit 1
pacstrap /mnt base base-devel btrfs-progs dosfstools gdisk efibootmgr rfkill reflector pciutils lm_sensors acpi zsh grml-zsh-config git docker docker-compose go julia python nodejs npm neovim keychain pass gnupg bspwm sxhkd feh mpv rofi termite chromium firefox thunderbird libinput xorg-server xorg-xinit xscreensaver xorg-xsetroot xorg-xdpyinfo xorg-xrandr xorg-xlsfonts xorg-xset intel-ucode networkmanager network-manager-applet networkmanager-openvpn lzop dunst libnotify upower xdo libva-${libvaDriver}-driver mesa-libgl imagemagick bc openssh openssh-askpass mopidy pulseaudio pulseaudio-alsa pavucontrol sdl python-neovim expac htop xf86-input-libinput redshift || exit 1

curl -# --create-dirs -fLo /mnt/etc/fstab $configAddr/etc/fstab  || exit 1
curl -# --create-dirs -fLo /mnt/boot/loader/loader.conf $configAddr/boot/loader/loader.conf  || exit 1
curl -# --create-dirs -fLo /mnt/boot/loader/entries/arch.conf $configAddr/boot/loader/entries/arch.conf  || exit 1
curl -# --create-dirs -fLo /mnt/boot/loader/entries/arch-verbose.conf $configAddr/boot/loader/entries/arch-verbose.conf  || echo "arch-verbose.conf entry not found"
curl -# --create-dirs -fLo /mnt/etc/locale.gen $configAddr/etc/locale.gen  || exit 1
curl -# --create-dirs -fLo /mnt/etc/locale.conf $configAddr/etc/locale.conf  || exit 1
curl -# --create-dirs -fLo /mnt/etc/vconsole.conf $configAddr/etc/vconsole.conf  || echo "vconsole.conf not found"

curl -# --create-dirs -fLo /mnt/root/install-chroot.sh $configAddr/install-chroot.sh  || exit 1

echo $hostname > /mnt/etc/hostname || exit 1
echo "127.0.0.1	$hostname.localdomain	$hostname" >> /mnt/etc/hosts || exit 1

chmod +x /mnt/root/install-chroot.sh
echo "Now execute /root/install-chroot.sh $username"
arch-chroot /mnt || exit 1
echo "Done"
