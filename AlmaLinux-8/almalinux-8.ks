# AlmaLinux Live Media (Beta - experimental), with optional install option.
# Build: sudo livecd-creator --cache=~/livecd-creator/package-cache -c almalinux-8-live-mini.ks -f AlmaLinux-8-Live-mini

# Keyboard layouts
keyboard 'us'
# Disable the Setup Agent on first boot
firstboot --disable
# Accept Eula
eula --agreed
# Do not configure the X Window System
skipx
# System timezone
timezone US/Eastern
# System language
lang en_US.UTF-8
# Firewall configuration
firewall --enabled --service=mdns
# Repos
url --url http://mirror.csclub.uwaterloo.ca/almalinux/8.4/BaseOS/x86_64/os/
# AlmaLinux repos, use https://mirros.almalinux.org to find and change different mirror
repo --name=baseos --baseurl="http://mirror.csclub.uwaterloo.ca/almalinux/8.4/BaseOS/x86_64/os/"
repo --name=appstream --baseurl="http://mirror.csclub.uwaterloo.ca/almalinux/8.4/AppStream/x86_64/os/"
repo --name=extras --baseurl="https://ord.mirror.rackspace.com/almalinux/8/extras/x86_64/os/"
repo --name=powertools --baseurl="https://ord.mirror.rackspace.com/almalinux/8/PowerTools/x86_64/os/"
# epel repo, use https://mirrors.fedoraproject.org/mirrorlist?repo=epel-8&arch=x86_64 for mirror list
repo --name=epel --baseurl="https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/"
## elrepo use https://mirrors.elrepo.org/mirrors-elrepo.el8 for mirror list
#repo --name=elrepo --baseurl="https://mirror.rackspace.com/elrepo/elrepo/el8/x86_64/"

# Network information
network --activate --bootproto=dhcp --device=link --onboot=on

# SELinux configuration
selinux --enforcing

# System services
services --disabled="sshd"

# livemedia-creator modifications.
shutdown
# System bootloader configuration
bootloader --location=none
# Clear blank disks or all existing partitions
clearpart --all --initlabel
rootpw rootme
# Disk partitioning information
part / --size=10238

%packages
@^minimal-environment
dracut-config-generic
dracut-live
grub2-efi
grub2-pc-modules
grub2-efi-x64-cdboot
kernel
# Make sure that DNF doesn't pull in debug kernel to satisfy kmod() requires
kernel-modules
kernel-modules-extra
memtest86+
nano
open-vm-tools
rsync
rsyslog
rsyslog-gnutls
rsyslog-gssapi
rsyslog-relp
shim-x64
syslinux
-@dial-up
-@input-methods
-gfs2-utils
# -dracut-config-rescue

# no longer in @core since 2018-10, but needed for livesys script
initscripts
chkconfig

%end
