#!/bin/bash
# cp -r ~/.ssh /root
# TODO Android automation support

HOME=/home/user
NET=10.11.13.0
MASK=24
IPr=10.11.13.1
IPh=10.11.13.$(($RANDOM%200+10))
TUNNEL=tun0
GW=eth0
IP=vpn.net

VPS=$2
if [ "$VPS" = "vpn" ] || [ "$VPS" = "" ]
then
	VPS="vpn"
fi
if [[ "$VPS" = "chaos" ]]
then
	VPS="chaos"
#	IP=tunnel.net
fi

bash ~/GhostInTheChaos/knock.sh

if [[ "$1" = "start" ]]
then
	socat -d tcp-listen:7443 openssl-connect:$IP:443,cert=~/GhostInTheChaos/cert.pem,verify=0 &
	ssh -C -S /var/run/ssh-vpn-tunnel-control -M -f -w 0:0 $VPS true &>/dev/null
	status=$?
#	if [ $status -ne 0 ] && [ $status -ne 255 ]
	if [[ $status -ne 0 ]]
	then
		echo 'Unable to establish the tunnel'
		killall socat
		exit 1
	fi
	sleep 5
	cp /etc/resolv.conf /root/resolv.conf.bk
	ip addr add $IPh/$MASK dev $TUNNEL
	ip link set $TUNNEL up
	echo "route add -host $IP gw $(ip r | grep def | cut -d ' ' -f 3) dev $(ip r | grep def | | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" > /root/route.gw
	bash < /root/route.gw
	route del default
	route add default gw $IPr dev $TUNNEL
	echo "nameserver 1.1.1.1" > /etc/resolv.conf
#	echo "nameserver $IPr" > /etc/resolv.conf

elif [[ "$1" = "stop" ]]
then
#	ssh l$VPS "sysctl -w net.ipv4.ip_forward=0" &>/dev/null
#	ssh l$VPS "iptables -t nat -D POSTROUTING -s $NET/$MASK -o $GW -j MASQUERADE" &>/dev/null
	ssh -S /var/run/ssh-vpn-tunnel-control -O exit l$VPS &>/dev/null
	sleep 5
	route del -host $IP
	cp /root/resolv.conf.bk /etc/resolv.conf
	route add default gw $(cat /root/route.gw | cut -d ' ' -f 6) dev $(cat /root/route.gw | cut -d ' ' -f 8)

else
	echo 'Usage : vpn start|stop [vpn|chaos]'
	exit 2
fi

