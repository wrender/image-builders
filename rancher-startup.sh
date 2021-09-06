#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Check if system is running in RAM
if cat /proc/1/cgroup | tail -1 | grep -q "container"; then
  echo "linux container"
else
  full_fs=$(df ~ | tail -1 | awk '{print $1;}')  # /dev/sda1
  fs=$(basename $full_fs)                        # sda1
  if grep -q "$fs" /proc/partitions; then
    LIVEOS=false
  else
    LIVEOS=true
  fi
fi


# Get OS Type and Release
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi


# Start of Rancher Kubernetes Cluster One
# Copy block and modify to create another cluster
if ([[ $(hostname) == ubuntu ]] || [[ $(hostname) == worker-a01-* ]]); then

# Join Cluster
RANCHERSERVER="https://dellserver.localdomain"
TOKEN="
-----BEGIN PGP MESSAGE-----

hQGMA9HghZf1WbwIAQv/Sc5G9ocHNP0WW1PppbA+5JleT5AhycgPmMXrTh7xkIcT
QEnsAvSgQAtSpzwxYMKVNQfjapAXh/TVMFyNlv3fOQFlpdbTKdJ5u+d4kbkoC63J
WLtWy/MKDrJ3wRny/i71QJSQsDweKYz+UEwX9iHUTE4TDPmu18gcBGapZzX87+Kj
2wx5HOlMYhKuEv05U2JcPOnnC9xWz8032Z8R1e1515Al3eLXM37Zzg4mIbBLyXkx
fPeuItaVJuvrq4MUxg1GQy6xity/0YfROMfROcqq0Uw9ZtxWIDh7EZfSnwgV88YJ
0Pv440SLcwP881wdggzKWfPqzV+qAwU5PJI9GvOhKTenQou3ND1XOOI90VD1agBL
mWAWSsjfQyVWt2HWZTwcZpjgg5Rh+ADuSZ8Sq3xa4Q3BBxaiOTyWtuA2xx0fU60D
yy0+cIjxt1Irr+mpcViLH3wifN0yG0njJCQzFbi4ySPEuKPj/KPWLJpmXclIEs24
Gmb/S+Sqv+wejrkqF3SF0nIB8f94zzVwlx5wbhryV/JXQzTBuuXJZ0HxfaePVCF5
OMYrMiL6PTUjL3m7hpji01l9NEqv/06ONhVlmyEGo35GErFGriKN8qZWb44v7qP1
x3rNX+lJ2S+fYGqwD3lSsfu67W3L0DkT4hPMSs/z6L5th8w=
=G5Ss
-----END PGP MESSAGE-----
"
CHECKSUM="7b8c4a244ca6e956a899e2af130751747994c1c509549c7dcb17061b22dd701f"
AGENTVERSION="2.5.9"

# Decrypt Token
DECRYPT=$(echo "$TOKEN" | gpg --decrypt --quiet)

  if [[ $LIVEOS == true ]]; then
    # Setup RAMDISK for Docker
    STORAGEPERCENTAGE=75 # For Diskless: Percentage of Memory to allocate for /var/lib/docker RAM Disk
    TOTALMEM=$(awk '/MemTotal/ { printf "%.3f \n", $2/1024 }' /proc/meminfo )
    MEMSTORAGE=$(echo "$TOTALMEM*0.$STORAGEPERCENTAGE/1" | bc )
    mount -t tmpfs -o size=$MEMSTORAGE'm' tmpfs /var/lib/docker
    systemctl enable docker && systemctl start docker
  fi

  # Example: Check if it is a live CentOS 7 OS and install Network driver
  if [[ $LIVEOS == true ]] && [[ $OS == 'CentOS Linux' ]] && [[ $VER == '7' ]]; then

    # Setup Myricom
    # Download & Install Drivers
    wget http://192.168.1.188/myrepo/myri_snf-3.0.25.50927_0b38e91d6.rhel-3486.x86_64.rpm -O /root/myri_snf.rpm
    rpm -Uvh /root/myri_snf.rpm
  fi

  if [[ $(hostname) == node-* ]]; then
    docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  "rancher/rancher-agent:v"$AGENTVERSION --server $RANCHERSERVER --token $DECRYPT --ca-checksum $CHECKSUM --etcd --controlplane
  else
    docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run  "rancher/rancher-agent:v"$AGENTVERSION --server $RANCHERSERVER --token $DECRYPT --ca-checksum $CHECKSUM --worker --etcd --controlplane
  fi
exit
fi
# END OF Rancher Cluster
