# GhostInTheChaos
Chaotic Crypto Stealth VPN for Anonymity and Untraceable Hacking Attacks with Linux and Android

![](https://github.com/cryptolok/GhostInTheChaos/raw/master/logo.jpg)

Properties:
* Protects client from sniffing and tracing
* Protects server from attacks and scanning
* Bypasses censorship and network filtering
* Transparent
* Cross-platform
* Minimalistic

Dependencies:
* **Linux 2.4.26+** - will work on any Linux-based OS (and can be ported to other Unix), including Whonix, RaspberryPI and even Android
	- BASH - the whole script
	- root privileges - for VPN (firewall controlling, but can be used without if manually configured (like Android))
	- [Termux](https://f-droid.org/en/packages/com.termux/) for Android
* **at least 1 (better 2) VPS/DEDIC remote/cloud server with Linux**

Limitations:
* If using anonymity option (2nd server) the speed will be greatly reduced (to prevent abuse)
* You should use domain name for the 1rst server to increase firewall bypass probability
* Traffic still can be identified and hence blocked using timing analysis
* Server still can be scanned, so you shouldn't rely only on "security by obscurity"

## How it works & Analysis

See my [blog](https://cryptolok.blogspot.com/2018/07/ghostinthechaos-chaotic-crypto-stealth.html) for research details.

![](https://github.com/cryptolok/GhostInTheChaos/raw/master/schema.png)

### HowTo

**VPN**

(Assuming you already have SSH/VNC access to your server with root privileges)

First of all, install everything that is needed of the same version:
```bash
apt install openssh-server socat iptables-persistent knockd
```

My SSH configuration requires specific options and plus it's hardened (except the root user, but it's just for PoC (even you can still harden it with SELinux/grsec/PAX/AppArmor/cgroups)), so copy VPN/sshd_config to /etc/ssh.

Now, generate a certificate in order to couple it with socat (both socat and openssl should be same version for client and server):
```bash
openssl ecparam -out cert.key -name secp521r1 -genkey
openssl req -new -key cert.key -x509 -nodes -days 365 -out cert.pem -sha256 -subj "/C=FR/ST=IDF/L=Paris/O=OrganizedOrganistion/OU=Org/CN=vpn.net"
cat cert.key >> cert.pem
rm cert.key
```
If you are considered by security, you can `cat /dev/random > cert.key`

It's time to set up the filtering rules, just copy the content of VPN/iptables.rules to /etc/iptables/rules.v4 and /etc/iptables/rules.v6 respectively, then apply them:
```bash
iptables-restore /etc/iptables/rules.v4
ip6tables-restore /etc/iptables/rules.v6
```

! WARNING ! it will block all the input traffic, so if in doubt, add a remote access port as exception until you stabilize your configuration

To finish the filtering copy VPN/knockd.conf to /etc, this will allow SSL:443 connection for socat over special condition, don't forget to daemonize the process if it wasn't done already by your OS:
```bash
systemctl enable knockd || echo '@reboot /usr/sbin/knockd -d' >> /var/spool/cron/crontabs/root
```
Alternatively, you can copy VPN/knockd.conf.alt if you want to redirect your connection to SSL in case you already have a HTTPS server (using an already generated certificate) for stealth.

In order to launch the socat itself, just put VPN/ssocat.sh to (as example) /root directory and crontab it:
```bash
@reboot /root/ssocat.sh
```
Or VPN/ssocat.sh.alt as HTTPS server alternative.

Finally, if you want a VPN-type connection, daemonize the script as well and put VPN/tunnel.sh to /root:
```bash
@reboot /root/tunnel.sh
```

**CHAOS (optional)**

If you want to test my "chaotic vpn/ssh/proxy" you will need a second server with following installations:
```bash
apt install openssh-server iptables-persistent
```

! WARNING ! this server shouldn't be accessed directly, in order to leave no trace (free WiFi or Tor), this is the "bulletproof" server.

For I2P, you should manually [install/download](https://geti2p.net/en/download) it both for CHAOS server and VPN server. Don't forget to make sure that it's daemonized:
```bash
systemctl enable i2p || echo "@reboot /usr/bin/i2prouter" >> /var/spool/cron/crontab/root
```

SSH configuration is the same as in case of VPN.

iptables rules are a bit different however, but still should be copied to /etc/iptables and "restored", just like for VPN. The main difference is that it accepts UDP (for I2P) INPUT for both IPv4 and IPv6.

! WARNING ! just like in the case of VPN, these rules will block almost all connections, so make sure you know what you're doing and make backups...

Finally, the [I2P](http://localhost:7657/i2ptunnel/) configurations can be found in both VPN/ and CHAOS/ directories in correct order. To do it on both servers, you can access them using SSH [DPF](https://www.linuxbabe.com/firewall/ssh-dynamic-port-forwarding) (included in CLIENT conf).

In the case of CHAOS, you just configure new hidden standard service, with the described options, but note that I used 443 as port for my SSH, so you should replace it with 22. Afterwards, in the main configuration menu, you will see the server's hidden Base32 address ending with \*.b32.i2p that will be used for configuration of VPN's new standard client tunnel with, once again, port 22 and not 443.

**CLIENT**

Like in previous case, you would require some packages:
```bash
sudo apt install ssh socat netcat #knockd
```
Knock isn't necessary, unless you want to speedup the process (sacrificing stealth).

Then, generate public and private keys pair for SSH authentication and secure it:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
chmod -R 700 ~/.ssh
```
On both servers (VPN and CHAOS) authorize your public key for connection:
```bash
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
```
I would advise removing the 'root@vpn.net' part in the end of public key, although, the PoC doesn't provide key passphrase automation, it should be compatible.

For SSH, just copy CLIENT/ssh to ~/.ssh/config.

Before continuing, replace $IP variable by your server in all scripts for CLIENT. Useless to say the all your scripts need to be `chmod u+x` (but if you're not that smart, perhaps, you shouldn't use such technology in the first place).

For socat, you have to transfer the cert.pem as well and to use the issh.sh script to initialize the SSH connection to the VPN:
```bash
cd ~/GhostInTheChaos
./issh.sh vpn
```
Replace "vpn" by "chaos" if you want the connection going through I2P.

Make sure that the required script (knock.sh) and cert.pem are in the same dirictory. Though, first connection would require to accept the public keys of both servers (so should be done by hand before automation).

That's it for SSH shell, X11 applications redirection (like VNC) and even proxy connection through browser using PortForwarding (port 8081 for VPN and 8082 for CHAOS).

Now the vpn, first you have to copy/alias your .ssh folder to /root (or use sudo for every network command):
```bash
cd ~/GhostInTheChaos
sudo ./vpn start
```
To stop it:
```bash
sudo ~/GhostInTheChaos/vpn.sh stop
```
You can also use vpn with CHAOS server:
```bash
sudo ./vpn.sh start chas
sudo ./vpn.sh stop
```

OK, it takes some time to set up, but when it's done, you can use it in few clicks (or aliases).

**ANDROID**

Everything has been tested on Android with Termux and the configuration is the same as for CLIENT. You still have to install the corresponding packages:
```bash
pkg install ssh socat netcat
```
Except that vpn connection will require root priveleges if using the script, but can also be done by manually configuring the network settings, anyway you still have PortForwarding and SSH, which is already enough for a smartphone, so vpn support is experimental at the moment.

Finally, don't hesitate to modify my scripts to suit your needs and limitations, as well as reading them in the first place :)

#### Notes

Firewall, IDPS, NGFW, UTM, DPI, AI, are all made by human intelligence, which will fall in the face of a stronger intelligence, human or not.

Chaos can be used for order and order can be used for chaos.

Order is impossible without chaos and chaos is impossible without order.

> "Invention, it must be humbly admitted, does not consist in creating out of void but out of chaos."

Mary Wollstonecraft Shelley

> "Chaos was the law of nature; Order was the dream of man."

Henry Adams, *The Education of Henry Adams*

> "No structure, even an artificial one, enjoys the process of entropy. It is the ultimate fate of everything, and everything resists it."

Philip K. Dick, "Galactic Pot-Healer"

