# Download Current pre-built ISO Image
[AlmaLinux-8.4-x86_64-minimal-salt-live.iso](https://www.otherdata.com/custom-images/AlmaLinux-8.4-x86_64-minimal-salt-live.iso) | md5sum c471c7846453550dde5d6f214bd0b66b
- docker-ce, and salt-minion installed
# Download Current pre-built PXE Images
initrd - [initramfs-4.18.0-305.17.1.el8_4.x86_64.img](https://www.otherdata.com/custom-images/AlmaLinux-8.4/initramfs-4.18.0-305.17.1.el8_4.x86_64.img) | md5sum 958a3ba0343231e146d181047188edd5

vmlinuz - [vmlinuz-4.18.0-305.17.1.el8_4.x86_64](https://www.otherdata.com/custom-images/AlmaLinux-8.4/vmlinuz-4.18.0-305.17.1.el8_4.x86_64) | md5sum 8d97fa8fac40c84ba2a38a1080383016

live-rootfs - [live-rootfs.squashfs.img](https://www.otherdata.com/custom-images/AlmaLinux-8.4/live-rootfs.squashfs.img) | md5sum e471df32409bebcf2c39e9ab16a52aca  live-rootfs.squashfs.img

- docker-ce, and salt-minion installed
# Create a AlmaLinux 8 LiveCD
- Install a AlmaLinux 8 Minimal on a server or in a VM to build the images on
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
livemedia-creator --make-pxe-live --ks almalinux-8.ks --iso-name Almalinux8.4.iso --iso AlmaLinux-8.4-x86_64-minimal.iso
```
- Your iso should be created
