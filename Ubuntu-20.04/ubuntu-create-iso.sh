#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get install -y \
    binutils \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    fakeroot \
    p7zip-full \
    isolinux \

mkdir $HOME/ubuntu-custom

# Checkout bootstrap
debootstrap \
   --arch=amd64 \
   --variant=minbase \
   focal \
   $HOME/ubuntu-custom/chroot \
   http://us.archive.ubuntu.com/ubuntu/

# Configure external mount points
mount --bind /dev $HOME/ubuntu-custom/chroot/dev; mount --bind /run $HOME/ubuntu-custom/chroot/run

# Define chroot environment
cp ubuntu-chroot.sh $HOME/ubuntu-custom/chroot/

# Run scriptt inside of chroot to configure chroot
echo "Running configuration inside of chroot"
sleep 5
chroot $HOME/ubuntu-custom/chroot /bin/bash -c "su - -c /ubuntu-chroot.sh"

umount $HOME/ubuntu-custom/chroot/dev; umount $HOME/ubuntu-custom/chroot/run

# Remove chroot build file
rm -rf $HOME/ubuntu-custom/chroot/ubuntu-chroot.sh

cd $HOME/ubuntu-custom
mkdir -p image/{casper,isolinux,install}

cp chroot/boot/vmlinuz-**-**-generic image/casper/vmlinuz
cp chroot/boot/initrd.img-**-**-generic image/casper/initrd

cd $HOME/ubuntu-custom
touch image/ubuntu

cat <<EOF > image/isolinux/grub.cfg

search --set=root --file /ubuntu

insmod all_video

set default="0"
set timeout=10

menuentry "Ubuntu 20.04 Live" {
   linux /casper/vmlinuz boot=casper quiet splash ---
   initrd /casper/initrd
}
menuentry "Install Ubuntu FS" {
   linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
   initrd /casper/initrd
}
EOF

# Create manifest
cd $HOME/ubuntu-custom
chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' | tee image/casper/filesystem.manifest
cp -v image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' image/casper/filesystem.manifest-desktop
sed -i '/casper/d' image/casper/filesystem.manifest-desktop
sed -i '/discover/d' image/casper/filesystem.manifest-desktop
sed -i '/laptop-detect/d' image/casper/filesystem.manifest-desktop
sed -i '/os-prober/d' image/casper/filesystem.manifest-desktop

# Compress the chroot
cd $HOME/ubuntu-custom
mksquashfs chroot image/casper/filesystem.squashfs
printf $(du -sx --block-size=1 chroot | cut -f1) > image/casper/filesystem.size

# Create diskdefines
cd $HOME/ubuntu-custom
cat <<EOF > image/README.diskdefines
#define DISKNAME  Ubuntu from scratch
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  amd64
#define ARCHamd64  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF

# Create ISO Image for a LiveCD (BIOS + UEFI)
cd $HOME/ubuntu-custom/image

grub-mkstandalone \
   --format=x86_64-efi \
   --output=isolinux/bootx64.efi \
   --locales="" \
   --fonts="" \
   "boot/grub/grub.cfg=isolinux/grub.cfg"

(
   cd isolinux && \
   dd if=/dev/zero of=efiboot.img bs=1M count=10 && \
   sudo mkfs.vfat efiboot.img && \
   LC_CTYPE=C mmd -i efiboot.img efi efi/boot && \
   LC_CTYPE=C mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
)

grub-mkstandalone \
   --format=i386-pc \
   --output=isolinux/core.img \
   --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
   --modules="linux16 linux normal iso9660 biosdisk search" \
   --locales="" \
   --fonts="" \
   "boot/grub/grub.cfg=isolinux/grub.cfg"

cat /usr/lib/grub/i386-pc/cdboot.img isolinux/core.img > isolinux/bios.img

/bin/bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt)"

xorriso \
   -as mkisofs \
   -iso-level 3 \
   -full-iso9660-filenames \
   -volid "Ubuntu from scratch" \
   -output "../ubuntu-20.04.3-live-server-salt-amd64.iso" \
   -eltorito-boot boot/grub/bios.img \
      -no-emul-boot \
      -boot-load-size 4 \
      -boot-info-table \
      --eltorito-catalog boot/grub/boot.cat \
      --grub2-boot-info \
      --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
   -eltorito-alt-boot \
      -e EFI/efiboot.img \
      -no-emul-boot \
   -append_partition 2 0xef isolinux/efiboot.img \
   -m "isolinux/efiboot.img" \
   -m "isolinux/bios.img" \
   -graft-points \
      "/EFI/efiboot.img=isolinux/efiboot.img" \
      "/boot/grub/bios.img=isolinux/bios.img" \
      "."
