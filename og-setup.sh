#!/bin/bash

#Install dependencies

sudo apt-get -q update
sudo apt-get -q install -y cmake mg make git gcc linux-headers-`uname -r` linux-image-extra-$(uname -r) libncursesw5 libncurses5 libtinfo5 git


# Allocate 1024 hugepages of 2 MB
# Change can be validated by executing 'cat /proc/meminfo | grep Huge'
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# Allocate 1024 hugepages of 2 MB at startup
echo "vm.nr_hugepages = 1024" >> /etc/sysctl.conf

# Set /mnt/huge
mkdir -p /mnt/huge && mount -t hugetlbfs nodev /mnt/huge
echo "hugetlbfs /mnt/huge hugetlbfs rw,mode=0777 0 0" >> /etc/fstab

# disable reverse path filtering, so e.g. a host can reply to ping packets for
# destination address A it receives on an interface bound to address != A
#
# this setting usually is disabled per interface, we use all and default
# to disable for all interfaces. See this email for how 'all' and 'default'
# and 'rp_filter' work together: https://marc.info/?l=linux-kernel&m=123606366021995&w=2
echo "0" > /proc/sys/net/ipv4/conf/all/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/default/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/enp0s10/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/enp0s16/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/enp0s17/rp_filter
echo "net.ipv4.conf.default.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.enp0s10.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.enp0s16.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.enp0s17.rp_filter = 0" >> /etc/sysctl.conf

# enable ip forwarding, so packets can be passed to different interfaces
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# Install the uio_pci_generic driver
modprobe uio_pci_generic

# Load modules at boot
echo "uio" >> /etc/modules
echo "uio_pci_generic" >> /etc/modules

echo "cd /vagrant" >> /home/vagrant/.bashrc
