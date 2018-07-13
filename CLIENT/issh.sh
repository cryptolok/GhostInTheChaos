#!/bin/bash

VPS=$1
IP=vpn.net


if [ "$VPS" != "vpn" ] && [ "$VPS" != "chaos" ]
then
	echo 'Usage : issh vpn|chaos'
	exit 1
fi

socat -d tcp-listen:7443 openssl-connect:$IP:443,cert=~/GhostInTheChaos/cert.pem,verify=0 &
bash ~/GhostInTheChaos/knock.sh
ssh $VPS
# certificate verification isn't necessary since SSH is used for that purpose

#fuser -k 7443/tcp
killall socat

