#!/bin/bash

IP=vpn.net

# universal stealth version for both Linux and Android:

nc -w 1 -i 1 $IP 443 &
sleep 1
nc -w 1 -i 1 $IP 80 &
sleep 1

nc -w 1 -i 1 $IP 443 &
sleep 1
nc -w 1 -i 1 $IP 80 &
sleep 1

nc -w 1 -i 1 $IP 443 &
sleep 1
nc -w 1 -i 1 $IP 80 &
sleep 1

# three times are enough for a normal usage

killall nc

# for more speed and less stealth on Linux (without 'sleep'):
#knock $IP 443 80 443 80
#sleep 1
#knock $IP 443 80 443 80
#sleep 1
#knock $IP 443 80 443 80
#sleep 1

