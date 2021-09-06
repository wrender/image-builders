# Image Builders

Simple bash scripts to build Custom OS images for use with Rancher/Kubernetes/SaltStack. A SaltStack formula to configure docker on the nodes after they have booted.

- Images for [Fedora CoreOS](https://github.com/wrender/image-builders/tree/main/CoreOS), [CentOS 7](https://github.com/wrender/image-builders/tree/main/CentOS-7), [CentOS 8 Stream](https://github.com/wrender/image-builders/tree/main/CentOS-8-Stream) and [Ubuntu 20.04](https://github.com/wrender/image-builders/tree/main/Ubuntu-20.04)
- Images include docker, salt-minion packages
- LiveOS and Persistant
- Salt-minion systemd service is enabled by default
- Docker systemd service is disabled by default (to be configured by SaltStack)
- rke-docker SaltStack Formula - Support Docker LiveOS/RAMDISK, Supports RKE

## Rancher-startup.sh

Example bash script that controls:
- Detects LiveOS/Immutable OS or Persistent
- How docker is started
- Provisions etc, controlplane and worker nodes by hostname

Usage:
1. Put rancher-startup.sh on your private web server
2. Modify the cluster, hostname matching if statement, rancher token etc.
3. GPG encrypt your Rancher token: `echo "7cgwjqr68tdmrhht2nl5jh5v22gqscq9fctn8pqfq2xdqwgzv47lhn" | gpg --encrypt -r RancherStartup --armor`
4. TODO: Convert to SaltStack formula 

## CentOS 7/8  Image Instructions
1.  Edit the kickstart file and edit the path to your webserver where you will host RancherStartup

2.  For CentOS 7 and 8 generate a ISO using the command. Ensure the image you are creating is built on the same version of OS you run livemedia-creator on:
```
livecd-creator --verbose --config=./kickstart-7.ks --fslabel=Rancher --cache=/var/cache/ 
```

3.  Put rancherstartup.sh on your web server so that it is accessable

4.  On the rancherstartup.sh file on your webserver, edit the hostname matching, tokens, checksum, and rancher agent version.

## Fedora CoreOS Image
1.  Create a butane configuration file and host it on your webserver.  Should include a unit like this:
```
# Create a script to grab the Rancher Startup Script
variant: fcos
version: 1.4.0
systemd:
  units:
    - name: runonce.service
      enabled: true
      contents: |
        [Unit]
        Description=RunOnce
        Requires=network-online.target
        After=network-online.target

        [Service]
        ExecStart=/tmp/runonce.sh

        [Install]
        WantedBy=multi-user.target

storage:
  files:
    - path /tmp/runonce.sh
    mode: 644
    contents: |
      #!/bin/bash

      if [ ! -f /tmp/registered.lock ]
      then
          wget http://my.webserver.com/rancherstartup.sh -O /root/rancherstartup.sh
          chmod +x /tmp/rancherstartup.sh
          touch /tmp/registered.lock
          sh /tmp/rancherstartup.sh
      exit
      fi
```

2. Edit the wget parameter to the path of your webserver where rancherstartup.sh is hosted

3. In the rancherstartup.sh on your webserver, edit the hostname matching, tokens, checksum, and rancher agent version

4. Boot your Fedora CoreOS, and it should join the rancher cluster

## TODO
- Setup SELINUX on RAM Disk for CentOS 7/8
- Setup NFS /etc/idmapd.conf configuraton
