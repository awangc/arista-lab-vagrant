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

mkdir -p /etc/gobgp
cat << GOBGPD_CONF > /etc/gobgp/gobgpd.conf
global:
  config:
    as: ${3}
    router-id: ${1}.${2}

neighbors:
  - config:
      neighbor-address: ${1}.252
      peer-as: ${3}
GOBGPD_CONF

#id gobgpd || useradd -r gobgpd
cp $GOPATH/bin/* /usr/local/sbin
mkdir -p /etc/gobgp
cp /vagrant/config/gobgpd.service /etc/systemd/system
systemctl daemon-reload

#cp /vagrant/config/ospfd.conf /etc/quagga
#cat >> /etc/quagga/ospfd.conf <<CONFIG
#router ospf
#  ospf router-id ${1}
#  network ${1}/32 area 0.0.0.0
#!
#line vty
#!
#CONFIG
#systemctl enable ospfd
#systemctl restart ospfd
touch /etc/quagga/vtysh.conf

cp /vagrant/config/zebra.conf /etc/quagga
systemctl enable zebra
systemctl restart zebra

echo "1" > /proc/sys/net/ipv4/ip_forward

# Allocate 1024 hugepages of 2 MB
# Change can be validated by executing 'cat /proc/meminfo | grep Huge'
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

# Allocate 1024 hugepages of 2 MB at startup
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
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
