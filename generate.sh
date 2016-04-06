#!/bin/bash

hosts=hosts.yml
inventory=inventory

if [ -e $hosts ]; then
    rm -f $hosts
fi
if [ -e $inventory ]; then
    rm -f $inventory
fi

while getopts ":l:n:y" opt; do
    case $opt in
      n)
        nodes=$OPTARG
	;;
      y)
	verify="y"
	;;
      \?)
        echo "Invalid option: -$OPTARG"
	exit 1
	;;
      :)
	echo "Option -$OPTARG requires an argument."
	exit 1
	;;
     esac
done

if ! [[ $nodes =~ ^-?[0-9]+$ ]]; then
    echo "You've entered an invalid input value!"
    exit 1
fi

if [[ $verify != "y" ]]; then
    echo -n "Create a web-cluster $nodes nodes? [y/n] "
    read verify
fi

if [[ $verify != "y" ]]; then echo "Aborting"; exit 1; fi

echo "Generating config-file".

echo "[lbs]
lb$l  ansible_ssh_host=192.168.10.10  ansible_ssh_user=vagrant  ansible_ssh_private_key_file=.vagrant/machines/lb$l/virtualbox/private_key" >> inventory
echo "---" >> $hosts
for l in `seq 1 $lbs`; do
    echo "- name: lb$l
  group: \"[lbs]\"
  box: \"ubuntu/wily64\"
  ip: 192.168.10.10
" >> $hosts
done

echo "[nodes]" >> inventory
for n in `seq 1 $nodes`; do
    ip=$(expr $n + 10)
    echo "- name: node$n
  group: \"[nodes]\"
  box: \"ubuntu/wily64\"
  ip: 192.168.10.$ip
" >> $hosts
echo "node$n  ansible_ssh_host=192.168.10.$ip  ansible_ssh_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/node$n/virtualbox/private_key" >> inventory
done


vagrant up
vagrant reload --provision
ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=/dev/null' ansible-playbook nginx.yml -i inventory 
