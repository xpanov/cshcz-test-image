#!/bin/sh -x

# install cloud support

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y cloud-init qemu-guest-agent cloud-guest-utils cloud-initramfs-growroot spice-vdagent

# copy custom cloud-init configuration (do not modify default apt source list)
sudo cp -f /tmp/cloud.cfg /etc/cloud/cloud.cfg

# enable cloud-init at boot time, disabled by standard Kali network service policy after installation
systemctl enable cloud-init
systemctl enable cloud-init-local.service
systemctl enable cloud-final.service
systemctl enable cloud-config.service

# with new ubuntu autoinstall installer cloud-init is run as part of the installation process, so we need to reset it
sudo cloud-init clean