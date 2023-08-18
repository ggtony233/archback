#!/bin/bash
ln -sf  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
sed -i 's/\#en_SG.UTF-8 UTF-8/en_SG.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/\#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
wait

echo 'LANG=en_SG.UTF-8' >> /etc/locale.conf
echo 'thinkpad-e480' >>/etc/hostname
echo -e '127.0.0.1 localhost\n::1 localhost\n127.0.1.1 thinkpad-e480.localdomain thinkpad-e480'
echo -e 'xutao911\nxutao911'|(passwd root)
wait
echo -e '[archlinuxcn]\nServer = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
pacman -Syu
wait
echo -e '\n'|(pacman -S grub efibootmgr os-prober archlinuxcn-keyring zsh)
echo -e '\n' |(pacman -S paru)
wait
sed -i 's/MODULES=()/MODULES=(btrfs xfs)/g' /etc/mkinitcpio.conf
mkinitcpio -P
wait
useradd -m -G wheel -s /bin/zsh ggtony
echo -e 'xutao911\nxutao911'|(passwd ggtony)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
wait
grub-mkconfig -o /boot/grub/grub.cfg