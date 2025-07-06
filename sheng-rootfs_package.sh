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

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\$PATH
export DEBIAN_FRONTEND=noninteractive

find $1/.. -name 'alsa-xiaomi-sheng.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'firmware-xiaomi-sheng.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'device-xiaomi-sheng.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'linux-xiaomi-sheng.deb' -exec cp "{}" $1/rootdir/  \;
chroot rootdir dpkg -i alsa-xiaomi-sheng.deb
chroot rootdir dpkg -i firmware-xiaomi-sheng.deb
chroot rootdir dpkg -i device-xiaomi-sheng.deb
chroot rootdir dpkg -i linux-xiaomi-sheng.deb
rm -rf $1/rootdir/*.deb


chroot rootdir /bin/bash -c "
useradd -m -s /bin/bash ubuntu
echo 'ubuntu:147147' | chpasswd
usermod -aG sudo ubuntu
"

umount rootdir/sys
umount rootdir/proc
umount rootdir/dev/pts
umount rootdir/data/local/tmp
umount rootdir/dev
umount rootdir

rm -d rootdir

7z a rootfs.7z rootfs.img
