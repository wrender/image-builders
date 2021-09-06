# Create a CentOS 7 LiveCD
- Install a CentOS 7 minimal on a server or in a VM to build the images on
- If using a VM, ensure Nested VT-x is enabled
- Disable SELINUX on CentOS 7
- Install packages needed:
```
yum install -y \
    livecd-tools \
    oscap-anaconda-addon \
    kmod-hfs \
    kmod-hfsplus \
    hfsplus-tools
```
- Git clone image-builders `git clone https://github.com/wrender/image-builders.git`
- Run livecd-creator
```
cd image-builders/CentOS-7;
livecd-creator \
--verbose \
--config=./kickstart-7.ks \
--fslabel=CentOS7LiveOS \
--cache=/var/cache/live
```
- Your iso should be created
