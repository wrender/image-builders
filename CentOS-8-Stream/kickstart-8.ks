#version=RHEL8
#ignoredisk --only-use=sda
# Partition clearing information
clearpart --all --initlabel
# Use text install
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# Network information
network  --bootproto=dhcp --device=link --ipv6=auto --activate

shutdown

# Set crypted Root password - https://access.redhat.com/solutions/44662
rootpw --plaintext password
# Disable the Setup Agent on first boot
firstboot --disable
# Accept Eula
eula --agreed


# Disk partitioning information
part / --size 4000 --fstype ext4

#============================= Package Selection ==============================#

url --url=http://mirror.csclub.uwaterloo.ca/centos/8-stream/BaseOS/x86_64/os/
repo --name="base" --baseurl=http://mirror.csclub.uwaterloo.ca/centos/8-stream/BaseOS/x86_64/os/
repo --name="updates" --baseurl=http://mirror.csclub.uwaterloo.ca/centos/8-stream/AppStream/x86_64/os/
repo --name="docker" --baseurl=http://download.docker.com/linux/centos/7/x86_64/stable/

%packages
@Core

# Needed for livemedia-creator Live ISO
dracut-live
syslinux-nonlinux
centos-logos
memtest86+

# For Kubenetes
docker
kernel-devel
gcc
make


%end

%addon com_redhat_kdump --disable --reserve-mb='auto'
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

