#!/usr/bin/env bash

apt-get update
apt-get install nginx -y

rm -f /var/www/html/index.html
hostname >> /var/www/html/index.html

if [[ $(hostname) =~ "lb" ]]; then
    rm -f /etc/nginx/sites-enabled/default
    ln -s /vagrant/nginx_lb.conf /etc/nginx/sites-enabled/default
    ln -s /vagrant/upstream /etc/nginx/conf.d/
    /etc/init.d/nginx reload
fi

    