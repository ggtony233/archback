#!/bin/bash
export Rdisk="/dev/nvme0n1p6"
export Rdir="/mnt"
export Boot="/dev/nvme0n1p1"
export Home="/dev/sda2"
export Gamed="/dev/nvme1n1p2"
export Swap="/dev/nvme0n1p5"
echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist 
echo "delete all old file in the boot disk!!!"
sleep 10
pacman -Syy
wait
mkswap $Swap
mkfs.btrfs -f $Rdisk
#mkfs.xfs -f $Home
wait
mount $Rdisk $Rdir
wait
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@usr_local
btrfs subvolume create /mnt/@var
wait
umount $Rdir
wait
#echo $Rdisk/12
mount $Rdisk $Rdir -o subvol=@,noatime,ssd,discard=async,compress=zstd
##rm /mnt/* -rf
mkdir "/mnt/usr/local" 
mkdir /mnt/var 
mount $Rdisk "/mnt/usr/local" -o subvol=@usr_local,noatime,ssd,discard=async,compress=zstd
mount $Rdisk $Rdir/var -o subvol=@var,ssd,noatime,discard=async,compress=zstd
rm /mnt/var/* -rf
mkdir /mnt/home
mkdir /mnt/boot 
mkdir -p /mnt/gamedisk
mount  $Gamed /mnt/gamedisk -o rw,noatime,uid=1000,gid=1000
mount $Boot /mnt/boot
mount $Home /mnt/home
wait
swapon $Swap
echo -e '\n' |(pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware networkmanager dhcpcd vim btrfs-progs amd-ucode xfsprogs ntfs-3g)
wait
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt 
 
