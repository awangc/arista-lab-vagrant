#!/bin/bash

#Install dependencies

sudo apt-get -q update
sudo apt-get -q install -y cmake mg make git gcc linux-headers-`uname -r` linux-image-extra-$(uname -r) libncursesw5 libncurses5 libtinfo5 git

# install quagga-core 1.2.4 from ubuntu/bionic64
wget -q http://launchpadlibrarian.net/361891995/quagga-core_1.2.4-1_amd64.deb > /dev/null
wget -q http://launchpadlibrarian.net/284875588/libreadline7_7.0-0ubuntu2_amd64.deb /dev/null
sudo dpkg -i libreadline7_7.0-0ubuntu2_amd64.deb quagga-core_1.2.4-1_amd64.deb
sudo rm -f libreadline7_7.0-0ubuntu2_amd64.deb quagga-core_1.2.4-1_amd64.deb

#Install and configure Go
export GO_VERSION=1.9.3

# set envvars for go
cat << EOF > /etc/profile.d/golang.sh
export GOROOT=/usr/local/go
export GOPATH=/usr/local/opt/gopath
export PATH=\$GOROOT/bin:\$PATH
EOF

source /etc/profile.d/golang.sh

# install go
mkdir -p $GOPATH
mkdir -p $GOROOT
cd $GOROOT/..
wget -q https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz > /dev/null 
tar zxf go${GO_VERSION}.linux-amd64.tar.gz

# install gobgp and gobgpd
go get -v github.com/osrg/gobgp/gobgpd
go get -v github.com/osrg/gobgp/gobgp
cp $GOPATH/bin/* /usr/local/sbin

mkdir -p /etc/gobgp

# config files will be copied via other ansible tasks


touch /etc/quagga/vtysh.conf

# disable reverse path filtering, so e.g. a host can reply to ping packets for
# destination address A it receives on an interface bound to address != A
#
# this setting usually is disabled per interface, we use all and default
# to disable for all interfaces. See this email for how 'all' and 'default'
# and 'rp_filter' work together: https://marc.info/?l=linux-kernel&m=123606366021995&w=2
echo "0" > /proc/sys/net/ipv4/conf/all/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/default/ip_filter
echo "0" > /proc/sys/net/ipv4/conf/enp0s8/rp_filter
echo "0" > /proc/sys/net/ipv4/conf/enp0s9/rp_filter
echo "net.ipv4.conf.default.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.enp0s8.rp_filter = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.enp0s9.rp_filter = 0" >> /etc/sysctl.conf

# enable ip forwarding, so packets can be passed to different interfaces
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# Allocate 1024 hugepages of 2 MB
# Change can be validated by executing 'cat /proc/meminfo | grep Huge'
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# Allocate 1024 hugepages of 2 MB at startup
echo "vm.nr_hugepages = 1024" >> /etc/sysctl.conf

# Set /mnt/huge
mkdir -p /mnt/huge && mount -t hugetlbfs nodev /mnt/huge
echo "hugetlbfs /mnt/huge hugetlbfs rw,mode=0777 0 0" >> /etc/fstab

# Install the uio_pci_generic driver
# modprobe uio_pci_generic

# Load modules at boot
#echo "uio" >> /etc/modules
#echo "uio_pci_generic" >> /etc/modules

echo "cd /vagrant" >> /home/vagrant/.bashrc
