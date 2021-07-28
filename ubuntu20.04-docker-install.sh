#!/bin/bash
### Written by Dmitry Efremov https://github.com/defremov-cscart
### Check OS version
set -e
 if cat /etc/*release | grep ^PRETTY_NAME | grep "Ubuntu 20.04"; then
    echo "==============================================="
    echo "Installing on Ubuntu 20.04"
    echo "==============================================="

echo -e "\n Prepare config for overlay2...\n "
mkdir /etc/docker
touch /etc/docker/daemon.json

echo '{
    "dns": ["1.1.1.1"],
	  "storage-driver": "overlay2",
	  "storage-opts": [
 	   "overlay2.override_kernel_check=true"
	  ]
	}' > /etc/docker/daemon.json

echo -e "\n Tuning GRUB config...\n "
sed -i 's/GRUB_CMDLINE_LINUX\s*=.*/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/g' /etc/default/grub
update-grub

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
apt-get update -y
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update -y
apt install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
systemctl enable docker
usermod -aG docker $USER
apt -y install python3-pip
pip3 install -U pip
pip3 install docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

echo -e "\n ====YOU NEED TO REBOOT SERVER====\n "

 else
    echo "WRONG OS VERSION, couldn't install"
    exit 1;
 fi

exit 0
