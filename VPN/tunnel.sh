#!/bin/bash
#crotntab @reboot
#apt install socat

NET=10.11.13.0
MASK=24
IPr=10.11.13.1
TUNNEL=tun0
GW=eth0


/sbin/sysctl -w net.ipv4.ip_forward=1
/sbin/iptables -t nat -I POSTROUTING 1 -s $NET/$MASK -o $GW -j MASQUERADE

while true
do
	ip l | grep tun0 | grep -v UP
	if [[ $? = 0 ]]
	then
		ip addr add $IPr/$MASK dev $TUNNEL
		ip link set $TUNNEL up
	fi
	sleep 1
done

