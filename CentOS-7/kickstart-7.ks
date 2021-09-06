install
text
lang en_US
keyboard 'us'
timezone Etc/UTC
firstboot --disabled

zerombr
clearpart --all --initlabel
autopart --type=lvm --encrypted --passphrase=password
bootloader --location=mbr --append="net.ifnames=0 biosdevname=0"

network --bootproto=dhcp --device=eth0 --noipv6

auth --useshadow  --passalgo=sha512
rootpw --iscrypted $6$DjDtms3NRugYYVBG$YPXxAS1Ox7lL34r6Y0qV8RywwHNdN5cI53qx6L0xxwF7lanwTQ88lU1m32pF1TAqM2mySTCs/WQb4U9xid7mb1

selinux --disabled
firewall --disabled

%addon com_redhat_kdump --disabled
%end


#============================= Package Selection ==============================#

repo --name="base" --baseurl=http://mirror.centos.org/centos/7/os/x86_64/
repo --name="updates" --baseurl=http://mirror.centos.org/centos/7/updates/x86_64/
repo --name="extra" --baseurl=http://mirror.centos.org/centos/7/extras/x86_64/
repo --name="epel" --baseurl=http://mirror.mrjester.net/fedora/epel/7/x86_64/
repo --name="docker" --baseurl=http://download.docker.com/linux/centos/7/x86_64/stable/

%packages --excludedocs --multilib --instLangs en_US

@core
kernel
kernel-devel
gcc
make
wget

docker

# BIOS/UEFI Cross-Compatibility Packages
efibootmgr
grub2-efi-x64
grub2-efi-x64-cdboot
grub2-efi-x64-modules
grub2-pc
grub2-pc-modules
grub2-tools*
shim-x64

%end


%post --log=/root/ks-post.log

# Create a script to grab the Rancher Startup Script
cat << EOF > /root/runonce.sh
#!/bin/bash

if [ ! -f /root/registered.lock ]
then
    wget http://192.168.1.188/myrepo/rancher-startup.sh -O /root/rancher-startup.sh
    chmod +x /root/rancher-startup.sh
    touch /root/registered.lock
    sh /root/rancher-startup.sh
    exit
fi
EOF
chmod +x /root/runonce.sh

# Service to get configuration
cat << EOF > /etc/systemd/system/runonce.service
[Unit]
Description=RunOnce
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/root/runonce.sh


[Install]
WantedBy=multi-user.target
EOF
chmod 664 /etc/systemd/system/runonce.service
systemctl enable runonce

%end 

