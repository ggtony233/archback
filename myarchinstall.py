#!/usr/bin/python3
import subprocess

rootpasswd = ""
upasswd = ""

# 设置时区
subprocess.run(["ln", "-sf", "/usr/share/zoneinfo/Asia/Shanghai", "/etc/localtime"])

# 更新硬件时钟
subprocess.run(["hwclock", "--systohc"])

# 配置 locale
locale_gen = "/etc/locale.gen"
subprocess.run(["sed", "-i", "s/#en_SG.UTF-8 UTF-8/en_SG.UTF-8 UTF-8/", locale_gen])
subprocess.run(["sed", "-i", "s/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/", locale_gen])
subprocess.run(["locale-gen"])

# 设置系统语言
with open("/etc/locale.conf", "a") as f:
    f.write("LANG=en_SG.UTF-8\n")

# 设置主机名
with open("/etc/hostname", "a") as f:
    f.write("myarch\n")

# 设置 hosts 文件
with open("/etc/hosts", "a") as f:
    f.write("127.0.0.1 localhost\n")
    f.write("::1 localhost\n")
    f.write("127.0.1.1 myarch.localdomain myarch\n")

# 修改 root 密码
subprocess.run(["passwd", "root"], input=(rootpasswd + "\n" + rootpasswd + "\n").encode())

# 添加 ArchlinuxCN 软件源
with open("/etc/pacman.conf", "a") as f:
    f.write("[archlinuxcn]\n")
    f.write("Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch\n")

# 更新系统并安装软件包
subprocess.run(["pacman", "-Syu"])
subprocess.run(["pacman", "-S", "grub", "efibootmgr", "os-prober", "archlinuxcn-keyring", "zsh"])
subprocess.run(["pacman", "-S", "paru"])

# 配置 mkinitcpio
subprocess.run(["sed", "-i", "s/MODULES=()/MODULES=(btrfs xfs)/", "/etc/mkinitcpio.conf"])
subprocess.run(["mkinitcpio", "-P"])

# 创建用户并设置密码
subprocess.run(["useradd", "-m", "-G", "wheel", "-s", "/bin/zsh", "ggtony"])
subprocess.run(["passwd", "ggtony"], input=(upasswd + "\n" + upasswd + "\n").encode())

# 安装 GRUB 引导程序
subprocess.run(["grub-install", "--target=x86_64-efi", "--efi-directory=/boot", "--bootloader-id=ArchLinux"])
subprocess.run(["grub-mkconfig", "-o", "/boot/grub/grub.cfg"])

