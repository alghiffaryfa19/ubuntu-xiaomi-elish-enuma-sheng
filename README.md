<!-- <img align="right" src="ubnt.png" width="305" alt="Ubuntu Running On Xiaomi Pad 6s Pro"> -->

# Ubuntu for Xiaomi Pad 6s Pro
This repo contians **Base Guide for installation/upgrading** and **Scripts for automatic building of Ubuntu RootFS, Mainline Kernel, Firmware package, ALSA configs** for Xiaomi Pad 6s Pro

# Where do I get the needed files?
Just go to the "Actions" tab, open the latest build and download files named **rootfs_(Desktop Environment)_(Kernel version)** and **boot-xiaomi-sheng_(Kernel version).img**
<br>For upgrading - download all available files, **except for rootfs**

## Upgrading steps (From running Ubuntu)
- Unpack all the .zip files you downloaded into one folder
- Open terminal and go to the folder where you unpacked all .zip files into
- Run "sudo dpkg -i *-xiaomi-sheng.deb"
- If you use flashing instead of **fastboot boot**: flash a new boot image using "dd if="**path to boot.img**" of=/dev/disk/by-partlabel/boot_**('a' or 'b')**"
- Reboot using new image

### Partitioning steps using "parted", where text inside () is a command to execute
⚠️**New partition should be at least 5GB in size for rootfs.img to fit in**
<br>⚠️**You will lose all your android data**
 - Download parted executable from the "Releases" tab
 - Reboot to TWRP recovery and push the downloaded file to /tmp <br>(**adb push parted /tmp**)
 - Access phone shell <br>(**adb shell**)
 - Grant execute permission and open parted for further steps<br>(**chmod +x /tmp/parted && /tmp/parted /dev/block/sda**)
 - Look at the partitions and remember "Number", "Start" "End" for "userdata" partition <br>(**print**)
 - Remove the "userdata" partition <br>(**rm "Number"**)
 - Create a new "userdata" partition <br>(**mkpart userdata f2fs "Start" "*End - size that you want to allocate for Ubuntu install*"**)
 - Create a new "linux" partition <br>(**mkpart linux ntfs "*End - size that you want to allocate for Ubuntu install*" "End"**)
 - Reboot back to recovery
 - Format the new "userdata" using TWRP format data function
 - Format the new "linux" partition <br>(**mkfs.ext4 /dev/block/by-name/linux**)
  
## Install steps
- You should have custom partitions, follow "Partitioning steps..."
- Unpack .zip files you downloaded
- Unpack extracted rootfs.7z
- rootfs.img must be flashed to the partition named "linux"
<br>⚠️**USE "dd if="path to rootfs.img" of=/dev/block/by-name/linux"
<br>  FLASHING USING FASTBOOT RESULTS IN BROKEN UBUNTU FILESYSTEM**
- Flash (or **fastboot boot**) boot.img that you got from boot archive
  


