export DEBIAN_FRONTEND=noninteractive

mount none -t proc /proc
mount none -t sysfs /sys
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

# echo "ubuntu-fs-live" > /etc/hostname

cat <<EOF > /etc/apt/sources.list
deb http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
deb http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
EOF

# Install Systemd
apt-get update;apt-get install -y libterm-readline-gnu-perl systemd-sysv

# Configure machine-id and divert
dbus-uuidgen > /etc/machine-id;ln -fs /etc/machine-id /var/lib/dbus/machine-id

dpkg-divert --local --rename --add /sbin/initctl; ln -s /bin/true /sbin/initctl

# Setup Keyboard
DEBIAN_FRONTEND=noninteractive apt-get install -y keyboard-configuration


apt-get install -y \
    sudo \
    casper \
    lupin-casper \
    network-manager \
    resolvconf \
    grub-common \
    grub-gfxpayload-lists \
    grub-pc \
    grub-pc-bin \
    grub2-common \
    make \
    gcc \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    gpg \
    bc \
    lsb-release

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
# Disable Docker as it will be configured later
systemctl disable docker

# Install SaltStack
# Download key
sudo curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
# Create apt sources list file
echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" | sudo tee /etc/apt/sources.list.d/salt.list
# Install Packages
apt-get update && apt-get install -y salt-minion && systemctl enable salt-minion
# Point to master
cat <<EOF > /etc/salt/minion.d/settings.conf
master: my.salt.masterhost
grains:
  roles:
    - k8s
EOF

# Install Initrd
apt-get install -y --no-install-recommends linux-generic initramfs-tools

# Remove machine-id
truncate -s 0 /etc/machine-id

rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl

# Set root password
sh -c 'echo root:password | chpasswd'

apt-get clean
rm -rf /tmp/* ~/.bash_history
umount /proc
umount /sys
umount /dev/pts
export HISTSIZE=0
exit
