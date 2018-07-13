#/bin/bash

apt install openssh-server iptables-persistent
# https://geti2p.net/en/download/
# systemctl enable i2p || crontab /usr/bin/i2prouter

cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod -R 700 ~/.ssh

