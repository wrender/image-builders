# Download Current pre-built Image
[AlmaLinux-8.4-x86_64-minimal-salt-live.iso](https://www.otherdata.com/custom-images/AlmaLinux-8.4-x86_64-minimal-salt-live.iso) (docker, salt-minion) | md5sum c471c7846453550dde5d6f214bd0b66b
# Create a CentOS 7 LiveCD
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
- Customize kickstart-8.ks as needed
- Download the AlmaLinux 8 boot iso from https://mirrors.almalinux.org/isos.html to the image-builders/AlmaLinux-8/ folder
- Run livecd-creator
```
cd image-builders/CentOS-8;
livemedia-creator --make-pxe-live --ks almalinux-8.ks --iso-name Almalinux8.4.iso --iso AlmaLinux-8.4-x86_64-minimal.iso
```
- Your iso should be created
