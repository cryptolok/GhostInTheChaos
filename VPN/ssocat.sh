#!/bin/bash
#crontab @reboot
#apt install socat

while true
do
	socat openssl-listen:443,reuseaddr,cert=cert.pem,cafile=cert.pem tcp:localhost:22
done

