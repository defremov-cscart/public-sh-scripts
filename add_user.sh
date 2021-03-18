#!/bin/bash
### Written by Dmitry Efremov https://github.com/defremov-cscart
echo -n "Enter username (e.g. iivanov) "

read -p 'Username: ' adduser

echo -n "Enter user's id_rsa.pub key "

read -p 'Key: ' sshkey


echo -n "Create user with $adduser name? (Y/n) "
read item
  case "$item" in
    y|Y) echo "Make some magic..." ;;
    n|N) echo "Exiting..." exit 0 ;;
    *) echo "Default choise is Yes, make some magic......"
    ;;
esac

sudo useradd -m -s /bin/bash $adduser
sudo mkdir /home/$adduser/.ssh
sudo sh -c "echo '$sshkey' >> /home/$adduser/.ssh/authorized_keys"
sudo chown -R $adduser: /home/$adduser/
sudo chmod -R  700 /home/$adduser/.ssh
sudo usermod -aG docker $adduser
