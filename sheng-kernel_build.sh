cd $1
git clone https://gitlab.postmarketos.org/jianhua/sm8250-mainline.git --depth 1 linux --branch $2
cd linux
wget https://gitlab.com/alghiffaryfa19/pkgbuilds/-/raw/dev/linux/sdm870/config-kupferlinux-qcom-sm8250.aarch64
cp config-kupferlinux-qcom-sm8250.aarch64 .config
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
_kernel_version="$(make kernelrelease -s)"


sed -i "s/Version:.*/Version: ${_kernel_version}/" $1/linux-xiaomi-elish/DEBIAN/control

chmod +x $1/mkbootimg

cat $1/linux/arch/arm64/boot/Image.gz $1/linux/arch/arm64/boot/dts/qcom/sm8250-xiaomi-elish-csot.dtb > $1/linux/Image.gz-dtb_csot
mv $1/linux/Image.gz-dtb_csot $1/linux/zImage_csot
$1/mkbootimg --kernel zImage_csot --cmdline "root=PARTLABEL=linux" --base 0x00000000 --kernel_offset 0x00008000 --tags_offset 0x00000100 --pagesize 4096 --id -o $1/boot_csot.img

cat $1/linux/arch/arm64/boot/Image.gz $1/linux/arch/arm64/boot/dts/qcom/sm8250-xiaomi-elish-boe.dtb > $1/linux/Image.gz-dtb_boe
mv $1/linux/Image.gz-dtb_boe $1/linux/zImage_boe
$1/mkbootimg --kernel zImage_boe --cmdline "root=PARTLABEL=linux" --base 0x00000000 --kernel_offset 0x00008000 --tags_offset 0x00000100 --pagesize 4096 --id -o $1/boot_boe.img

rm $1/linux-xiaomi-elish/usr/dummy
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=$1/linux-xiaomi-elish/usr modules_install
rm $1/linux-xiaomi-elish/usr/lib/modules/**/build
cd $1
rm -rf linux

dpkg-deb --build --root-owner-group linux-xiaomi-elish
