#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

apt-get update;

REQUIRED_PACKAGES=( ansible git wget )
for i in "${REQUIRED_PACKAGES[@]}"
do
  echo -n "Checking if $i installed... "
  if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "installing"
    apt-get install $i -y;
  else
    echo "ok"
  fi
done

_USER=${SUDO_USER:-$USER}
mkdir -p /home/$_USER/repos

if [ -d "/home/$_USER/repos/my-ansible" ]; then
  pushd /home/$_USER/repos/my-ansible
  git checkout master && git pull origin master
else
  pushd /home/$_USER/repos
  git clone https://github.com/benletchford/my-ansible
  pushd my-ansible
fi

chown -R $_USER:$_USER /home/$_USER/repos

ansible-playbook -i "localhost," -c local playbook.yml
