cd $1
git clone https://github.com/alghiffaryfa19/sm8550-mainline --depth 1 linux --branch sheng-$2-nanosic-led
cd linux

make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig sm8550.config
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
_kernel_version="$(make kernelrelease -s)"
sed -i "s/Version:.*/Version: ${_kernel_version}/" $1/linux-xiaomi-sheng/DEBIAN/control

chmod +x $1/mkbootimg

cat $1/linux/arch/arm64/boot/Image.gz $1/linux/arch/arm64/boot/dts/qcom/sm8550-xiaomi-sheng.dtb > $1/linux/Image.gz-dtb_sheng
mv $1/linux/Image.gz-dtb_sheng $1/linux/zImage_sheng
$1/mkbootimg --kernel zImage_sheng --cmdline "root=PARTLABEL=linux" --base 0x00000000 --kernel_offset 0x00008000 --tags_offset 0x01e00000 --pagesize 4096 --id -o $1/boot_sheng.img

#rm $1/linux-xiaomi-sheng/usr/dummy
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=$1/linux-xiaomi-sheng/usr modules_install
rm $1/linux-xiaomi-sheng/usr/lib/modules/**/build
cd $1
rm -rf linux

dpkg-deb --build --root-owner-group linux-xiaomi-sheng
