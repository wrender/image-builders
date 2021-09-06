# Option 1 - Create the ISO
- Edit settings in ubuntu-chroot.sh as needed. (password, salt etc..)
- Run the script ubuntu-create-iso.sh

# Option 2 - Download, Extracting, editing, and recreating the ISO
## Download the current ISO
https://www.otherdata.com/ubuntu-20.04.3-live-server-salt-amd64.iso (docker, salt-minion| md5sum 31abbaf496e54be101ca282a17725293

## Extract ISO
```
cd tmp;
xorriso -osirrox on -indev /root/ubuntu-custom/ubuntu-20.04.3-live-server-salt-amd64.iso -extract / /tmp/tmpiso
```

## Unsquash Filesystem
```
unsquashfs -f -d /tmp/tmpunsquash /tmp/tmpiso/casper/filesystem.squashfs
```

## Edit Salt Master Settings
```
vim /tmp/tmpunsquash/etc/salt/minion.d/settings.conf
```
## Resquash Filesytem
```
rm -rf /tmp/tmpiso/casper/filesystem.squashfs
mksquashfs /tmp/tmpunsquash /tmp/tmpiso/casper/filesystem.squashfs
```

## Re-Create ISO
```
cd /tmp/tmpiso;
xorriso \
   -as mkisofs \
   -iso-level 3 \
   -full-iso9660-filenames \
   -volid "Ubuntu Custom" \
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
   -append_partition 2 0xef EFI/efiboot.img \
   -m "EFI/efiboot.img" \
   -m "EFI/bios.img" \
   -graft-points \
      "/EFI/efiboot.img=EFI/efiboot.img" \
      "/boot/grub/bios.img=boot/grub/bios.img" \
      "."
```
## New bootable iso should be available in /tmp/