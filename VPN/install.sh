#!/bin/bash

apt install openssh-server socat iptables-persistent knockd
# https://geti2p.net/en/download/
# systemctl enable i2p || crontab /usr/bin/i2prouter

ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod -R 700 ~/.ssh
# remove root@vpn.net for .pub

openssl ecparam -out cert.key -name secp521r1 -genkey
openssl req -new -key cert.key -x509 -nodes -days 365 -out cert.pem -sha256 -subj "/C=FR/ST=IDF/L=Paris/O=OrganizedOrganistion/OU=Org/CN=vpn.net"
cat cert.key >> cert.pem
# cat /dev/urandom > cert.key
rm cert.key

