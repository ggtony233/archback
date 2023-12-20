#!/bin/bash
export Rdisk="/dev/nvme0n1p2"
export Rdir="/mnt"
echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist 
echo "delete all old file in the boot disk!!!"
sleep 10
pacman -Syy
wait
mkfs.btrfs -f $Rdisk
##仅首次安装
#mkfs.xfs -f "/dev/sda1"
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
mkdir /mnt/usr/local 
mkdir /mnt/var 
mount $Rdisk /mnt/usr/local subvol=@usr_local,noatime,ssd,discard=async,compress=zstd
mount $Rdisk $Rdir/var subvol=@var,ssd,noatime,discard=async,compress=zstd
rm /mnt/var/* -rf
mkdir /mnt/home
mkdir /mnt/boot 
mkdir -p /mnt/gamedisk
mount /dev/sda2 /mnt/gamedisk -o rw,noatime,uid=1000,gid=1000
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/sda1 /mnt/home
wait
swapon /dev/nvme0n1p3
echo -e '\n' |(pacstrap /mnt base base-devel linux-lts linux-lts-headers linux-firmware networkmanager dhcpcd vim btrfs-progs intel-ucode xfsprogs ntfs-3g)
wait
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt 
 
