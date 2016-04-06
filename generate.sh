#!/bin/bash

hosts=hosts.yml
upstream=upstream.conf

if [ -e $hosts ]; then
    rm -f $hosts
fi
if [ -e $upstream ]; then
    rm -f $upstream
fi

while getopts ":l:n:y" opt; do
    case $opt in
      l)
        lbs=$OPTARG
	;;
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

if ! [[ $lbs =~ ^-?[0-9]+$ ]] || ! [[ $nodes =~ ^-?[0-9]+$ ]]; then
    echo "You've entered an invalid input value!"
    exit 1
fi

if [[ $lbs -gt 9 ]] || [[ $nodes -gt 9 ]]; then
    echo "This script only supports adding 10 servers of each class";
    exit 1
fi

if [[ $verify != "y" ]]; then
    echo -n "Create a web-cluster with $lbs LBs and $nodes nodes? [y/n] "
    read verify
fi

if [[ $verify != "y" ]]; then echo "Aborting"; exit 1; fi

echo "Generating config-file".

echo "---" >> $hosts
for l in `seq 1 $lbs`; do
    ip=$(expr $l + 10)
    echo "- name: lb$l
  group: \"[lbs]\"
  box: \"ubuntu/wily64\"
  ip: 192.168.10.$ip
" >> $hosts
done

echo "upstream http {" >> $upstream
for n in `seq 1 $nodes`; do
    ip=$(expr $n + 20)
    echo "- name: node$n
  group: \"[nodes]\"
  box: \"ubuntu/wily64\"
  ip: 192.168.10.$ip
" >> $hosts
echo "server 192.168.10.$ip weight=5 max_fails=3 fail_timeout=10s;" >> $upstream
done
echo "}" >> $upstream


vagrant up
vagrant reload --provision
ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=/dev/null' ansible-playbook $1 -i inventory 
