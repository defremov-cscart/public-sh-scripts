#!/bin/bash
### Written by Dmitry Efremov https://github.com/defremov-cscart
### Check OS version
set -e
 if cat /etc/*release | grep ^PRETTY_NAME | grep "CentOS Linux 7"; then
    echo "==============================================="
    echo "Installing on CentOS"
    echo "==============================================="

echo -e "\n Importing and install repo...\n "
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
yum remove -y kernel-tools kernel-tools-libs
yum --enablerepo=elrepo-kernel install -y kernel-lt*

echo -e "\n Tuning GRUB config...\n "
sed -i 's/GRUB_DEFAULT\s*=.*/GRUB_DEFAULT=0/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

echo -e "\n Prepare config for overlay2...\n "
mkdir /etc/docker
touch /etc/docker/daemon.json

echo '{
	  "storage-driver": "overlay2",
	  "storage-opts": [
 	   "overlay2.override_kernel_check=true"
	  ]
	}' > /etc/docker/daemon.json

echo -e "\n Creating kernel config...\n "
touch /etc/sysctl.d/docker.conf
echo 'net.ipv6.conf.default.accept_ra_rtr_pref = 0
	net.ipv6.conf.default.accept_ra_pinfo = 0
	net.ipv6.conf.default.accept_ra_defrtr = 0
	net.ipv6.conf.default.autoconf = 0
	net.ipv6.conf.default.dad_transmits = 0
	net.ipv6.conf.default.max_addresses = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	net.bridge.bridge-nf-call-iptables = 1
' > /etc/sysctl.d/docker.conf
sysctl -p

echo -e "\n Installing packages...\n "
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker
usermod -aG docker $USER
yum -y install python3-pip
pip3 install -U pip
pip3 install docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
echo -e "\n ====YOU NEED TO REBOOT SERVER====\n "

 else
    echo "WRONG OS VERSION, couldn't install"
    exit 1;
 fi

exit 0
