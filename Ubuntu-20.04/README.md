1. Create an ipxe chain loading boot file. Point it to a ipxe boot file on an internal http server. Create a boot file with something like:
```
#!ipxe

set base http://192.168.1.142/tftp/ltsp/

# The "images" method can boot anything in /srv/ltsp/images
set cmdline_method root=/dev/nfs nfsroot=192.168.1.226:/srv/ltsp ltsp.image=images/focal.img loop.max_part=9

set cmdline ${cmdline_method}
# In EFI mode, iPXE requires initrds to be specified in the cmdline
kernel ${base}vmlinuz initrd=ltsp.img initrd=initrd.img ${cmdline}
initrd ${base}ltsp.img
initrd ${base}initrd.img

boot

```

2. Install and Ubuntu 20.04 Server, and then install ltsp and ltsp-binaries
```
apt install -y --install-recommends ltsp ltsp-binaries openssh-server squashfs-tools ethtool net-tools
```
3. Follow the directions at https://github.com/ltsp/ltsp/wiki/chroots and create a chroot environment

4. Copy the ltsp config file into place:  `install -m 0660 -g sudo /usr/share/ltsp/common/ltsp/ltsp.conf /etc/ltsp/ltsp.conf`

5. Edit /etc/ltsp/ltsp.conf and add IMAGE_TO_RAM=1 and set a root password if needed:
```
[clients]
# Allow local root logins by setting a password hash for the root user.
# The hash contains $, making it hard to escape in POST_INIT_x="sed ...".
# So put sed in a section and call it at POST_INIT like this:
POST_INIT_SET_ROOT_HASH="section_set_root_hash"

# This is the hash of "qwer1234"; cat /etc/shadow to see your hash.
[set_root_hash]
sed 's|^root:[^:]*:|root:$6$VRfFL349App5$BfxBbLE.tYInJfeqyGTv2lbk6KOza3L2AMpQz7bMuCdb3ZsJacl9Nra7F/Zm7WZJbnK5kvK74Ik9WO2qGietM0:|' -i /etc/shadow

IMAGE_TO_RAM=1
```
6. Generate the images with `ltsp image focal` (This creates an image based on /srv/ltsp/focal)

7. Run `ltsp intrd` to generate the ltsp.img.

8. Copy the initrd.img, vmlinuz, focal.img, and ltsp.img to your internal web server. For example: http://192.168.1.142/tftp/ltsp/

9. Copy the files in /srv/ltsp  to your NFS server. Example: 192.168.1.226:/srv/ltsp

10. Create exports with something similar to:
```
# Export LTSP chroots and images
/srv/ltsp       *(ro,async,crossmnt,no_subtree_check,no_root_squash,insecure)

# Export TFTP_DIR over NFS as well, for synching local kernels and ltsp.img
/srv/tftp/ltsp  *(ro,async,crossmnt,no_subtree_check,no_root_squash,insecure)
```
