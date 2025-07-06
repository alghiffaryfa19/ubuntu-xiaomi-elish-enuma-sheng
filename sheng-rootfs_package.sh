#!/bin/sh

find $1/.. -name 'rootfs.7z' -exec mv "{}" $1/  \;

7z x rootfs.7z

mkdir rootdir
mount -o loop rootfs.img rootdir

mkdir -p rootdir/data/local/tmp
mount --bind /dev rootdir/dev
mount --bind /dev/pts rootdir/dev/pts
mount --bind /proc rootdir/proc
mount -t tmpfs tmpfs rootdir/data/local/tmp
mount --bind /sys rootdir/sys

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
export DEBIAN_FRONTEND=noninteractive

# Salin file .deb ke rootfs
find $1/.. -name 'alsa-xiaomi-elish.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'firmware-xiaomi-elish.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'device-xiaomi-elish.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'linux-xiaomi-elish.deb' -exec cp "{}" $1/rootdir/  \;

# Install paket-paket .deb
chroot rootdir dpkg -i alsa-xiaomi-elish.deb
chroot rootdir dpkg -i firmware-xiaomi-elish.deb
chroot rootdir dpkg -i device-xiaomi-elish.deb
chroot rootdir dpkg -i linux-xiaomi-elish.deb
rm -rf $1/rootdir/*.deb

# 🚀 Tambahkan user 'ubuntu' dengan password '147147'
chroot rootdir /bin/bash -c "
useradd -m -s /bin/bash ubuntu
echo 'ubuntu:147147' | chpasswd
usermod -aG sudo ubuntu
"

# Bersihkan dan unmount
umount rootdir/sys
umount rootdir/proc
umount rootdir/dev/pts
umount rootdir/data/local/tmp
umount rootdir/dev
umount rootdir

rm -d rootdir

7z a rootfs.7z rootfs.img
