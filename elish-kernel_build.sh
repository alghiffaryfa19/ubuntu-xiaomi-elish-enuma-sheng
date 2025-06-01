cd $1
git clone https://gitlab.postmarketos.org/jianhua/sm8250-mainline.git --depth 1 linux --branch $2
cd linux
wget https://gitlab.com/alghiffaryfa19/pkgbuilds/-/raw/dev/linux/sdm870/config-kupferlinux-qcom-sm8250.aarch64
cp config-kupferlinux-qcom-sm8250.aarch64 .config
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
_kernel_version="$(make kernelrelease -s)"

mkdir ../linux-xiaomi-elish/boot
cp $1/linux/arch/arm64/boot/Image.gz $1/linux-xiaomi-elish/boot/vmlinuz-$_kernel_version
cp $1/linux/arch/arm64/boot/dts/qcom/sm8250-xiaomi-elish-csot.dtb $1/linux-xiaomi-elish/boot/dtb-$_kernel_version

sed -i "s/Version:.*/Version: ${_kernel_version}/" $1/linux-xiaomi-elish/DEBIAN/control

chmod +x $1/mkbootimg

cat $1/linux/arch/arm64/boot/Image $1/linux/arch/arm64/boot/dts/qcom/sm8250-xiaomi-elish-csot.dtb > $1/linux/Image_w_dtb
gzip Image_w_dtb
$1/mkbootimg --header_version 0 --base 0x0 --cmdline "clk_ignore_unused pd_ignore_unused root=PARTLABEL=linux" --kernel $1/linux/Image_w_dtb.gz -o $1/boot_csot.img

cat $1/linux/arch/arm64/boot/Image $1/linux/arch/arm64/boot/dts/qcom/sm8250-xiaomi-elish-boe.dtb > $1/linux/Image_w_dtb
gzip Image_w_dtb
$1/mkbootimg --header_version 0 --base 0x0 --cmdline "clk_ignore_unused pd_ignore_unused root=PARTLABEL=linux" --kernel $1/linux/Image_w_dtb.gz -o $1/boot_boe.img

rm $1/linux-xiaomi-elish/usr/dummy
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=$1/linux-xiaomi-elish/usr modules_install
rm $1/linux-xiaomi-elish/usr/lib/modules/**/build
cd $1
rm -rf linux

dpkg-deb --build --root-owner-group linux-xiaomi-elish
