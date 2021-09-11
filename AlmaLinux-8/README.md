# Download Current pre-built ISO Image
[boot.iso](https://www.otherdata.com/custom-images/AlmaLinux-8/boot.iso) | md5sum 80171124ce52c3718a1bb1453d6f1ae0

# Download Current pre-built PXE Images
initrd.img - [initrd.img](https://www.otherdata.com/custom-images/AlmaLinux-8/initrd.img) | md5sum a13972a1e60dc9e7fc95116177060904

vmlinuz - [vmlinuz](https://www.otherdata.com/custom-images/AlmaLinux-8/vmlinuz) | md5sum 8d97fa8fac40c84ba2a38a1080383016

install.img - [live-rootfs.squashfs.img](https://www.otherdata.com/custom-images/AlmaLinux-8/install.img) | md5sum 3f6a3541269926e72e5e9d540d67dd60

### Example iPXE Boot
```
#!ipxe

set base http://192.162.1.142/tftp

kernel ${base}/vmlinuz initrd=main root=live:http://192.162.1.142/tftp/install.img
initrd --name main ${base}/initrd.img

boot
```
# Create a AlmaLinux 8 LiveCD
- Install a AlmaLinux 8 Minimal on a server or in a VM to build the images on. (I tested this using VirtualBox, but had issues. I ended up building the images on baremetal with VT-x enabled in the bios).
- If using a VM, ensure Nested VT-x is enabled
- Disable SELINUX
- Install packages needed:
```
sudo dnf -y install epel-release elrepo-release
sudo dnf -y update
sudo dnf --enablerepo="powertools" --enablerepo="epel" --enablerepo="elrepo" install anaconda\
                livecd-tools \
                hfsplus-tools \
                efibootmgr \
                efi-filesystem \
                efi-srpm-macros \
                efivar-libs \
                grub2-efi-x64 \
                grub2-efi-x64-cdboot \
                grub2-tools-efi \
                shim-x64
dnf module install -y virt;
```
- Git clone image-builders `git clone https://github.com/wrender/image-builders.git`
- Customize almalinux-8.ks as needed
- Download the AlmaLinux 8 boot iso from https://mirrors.almalinux.org/isos.html to the image-builders/AlmaLinux-8/ folder
- Run livecd-creator
```
cd image-builders/Almalinux-8;
livemedia-creator --make-iso --ks almalinux-8.ks --iso AlmaLinux-8.4-x86_64-minimal.iso
```
- Your iso and initrd, vmlinuz should be created in /var/tmp/
