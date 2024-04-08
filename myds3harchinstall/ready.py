#!/usr/bin/python3
import subprocess
import time

Rdisk = "/dev/nvme0n1p6"
Rdir = "/mnt"
Boot = "/dev/nvme0n1p1"
Home = "/dev/sda2"
Gamed = "/dev/nvme1n1p2"
Swap = "/dev/nvme0n1p5"

# 设置软件源
with open("/etc/pacman.d/mirrorlist", "w") as f:
    f.write('Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch\n')

print("delete all old file in the boot disk!!!")
time.sleep(10)

# 同步软件包数据库
subprocess.run(["pacman", "-Syy"])

# 创建 swap 分区
subprocess.run(["mkswap", Swap])

# 格式化根分区
subprocess.run(["mkfs.btrfs", "-f", Rdisk])

# 创建并挂载根分区子卷
subprocess.run(["mount", Rdisk, Rdir])
subprocess.run(["btrfs", "subvolume", "create", f"{Rdir}/@"], check=True)
subprocess.run(["btrfs", "subvolume", "create", f"{Rdir}/@usr_local"], check=True)
subprocess.run(["btrfs", "subvolume", "create", f"{Rdir}/@var"], check=True)
subprocess.run(["umount", Rdir])

subprocess.run(["mount", Rdisk, Rdir, "-o", "subvol=@,noatime,ssd,discard=async,compress=zstd"])
subprocess.run(["mkdir", "/mnt/usr/local"])
subprocess.run(["mkdir", "/mnt/var"])
subprocess.run(["mount", Rdisk, "/mnt/usr/local", "-o", "subvol=@usr_local,noatime,ssd,discard=async,compress=zstd"])
subprocess.run(["mount", Rdisk, f"{Rdir}/var", "-o", "subvol=@var,ssd,noatime,discard=async,compress=zstd"])
subprocess.run(["rm", "/mnt/var/*", "-rf"])
subprocess.run(["mkdir", "/mnt/home"])
subprocess.run(["mkdir", "/mnt/boot"])
subprocess.run(["mkdir", "-p", "/mnt/gamedisk"])
subprocess.run(["mount", Gamed, "/mnt/gamedisk", "-o", "rw,noatime,uid=1000,gid=1000"])
subprocess.run(["mount", Boot, "/mnt/boot"])
subprocess.run(["mount", Home, "/mnt/home"])

# 启用 swap
subprocess.run(["swapon", Swap])

# 安装基本系统
packages = ["base", "base-devel", "linux-lts", "linux-lts-headers", "linux-firmware",
            "networkmanager", "dhcpcd", "vim", "btrfs-progs", "amd-ucode", "xfsprogs", "ntfs-3g"]
subprocess.run(["pacstrap", "/mnt"] + packages)

# 生成 fstab
subprocess.run(["genfstab", "-U", "/mnt"], stdout=open("/mnt/etc/fstab", "a"))

# 进入 chroot 环境
subprocess.run(["arch-chroot", "/mnt"])

