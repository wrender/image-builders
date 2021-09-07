# Download Current pre-built Image
[CentOS-Stream-8-x86_64-20210902-boot.iso](https://www.otherdata.com/custom-images/CentOS-Stream-8-x86_64-20210902-boot.iso) (docker, salt-minion) | md5sum c471c7846453550dde5d6f214bd0b66b
# Create a CentOS 8 LiveCD
- Install a CentOS 8 Stream Minimal on a server or in a VM to build the images on
- If using a VM, ensure Nested VT-x is enabled
- Disable SELINUX on CentOS Stream 8
- Install packages needed:
```
dnf install -y \
    livecd-tools \
    lorax-lmc-virt \
    lorax-templates-rhel
```
- Git clone image-builders `git clone https://github.com/wrender/image-builders.git`
- Customize kickstart-8.ks as needed
- Run livecd-creator
```
cd image-builders/CentOS-8;
    livemedia-creator \
    --make-ostree-live \
    --tmp=/var/tmp/a \
    --ks kickstart-8.ks \
    --iso=CentOS-Stream-8-x86_64-20210902-boot.iso \
    --resultdir=/var/tmp/a/result
```
- Your iso should be created
