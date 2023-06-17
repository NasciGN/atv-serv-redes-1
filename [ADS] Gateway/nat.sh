#!/bin/bash

ALL=0.0.0.0
OUTPUT=enp0s3

HOST=192.168.56.0/24
REDE=172.16.1.0/24

GATEWAY=192.168.56.2
DNS1=172.16.1.2
DNS2=172.16.1.3
WEB=172.16.1.4
STORAGE=172.16.1.5

IP1=192.168.56.2
IP2=192.168.56.3

iptables -t nat -F
iptables -F

echo "1" >/proc/sys/net/ipv4/ip_forward

# SSH - DHCP / DNS I
iptables -A FORWARD -p tcp -s $HOST -d $DNS1 --dport 52000 -j ACCEPT
iptables -A FORWARD -p tcp -s $DNS1 -d $HOST --sport 52000 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -s $HOST -d $GATEWAY --dport 52000 -j DNAT --to $DNS1:22

# SSH - DNS II
iptables -A FORWARD -p tcp -s $HOST -d $DNS2 --dport 53000 -j ACCEPT
iptables -A FORWARD -p tcp -s $DNS2 -d $HOST --sport 53000 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -s $HOST -d $GATEWAY --dport 53000 -j DNAT --to $DNS2:22

# SSH - WEB
iptables -A FORWARD -p tcp -s $HOST -d $WEB --dport 54000 -j ACCEPT
iptables -A FORWARD -p tcp -s $WEB -d $HOST --sport 54000 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -s $HOST -d $GATEWAY --dport 54000 -j DNAT --to $WEB:22

# SSH - STORAGE
iptables -A FORWARD -p tcp -s $HOST -d $STORAGE --dport 55000 -j ACCEPT
iptables -A FORWARD -p tcp -s $STORAGE -d $HOST --sport 55000 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -s $HOST -d $GATEWAY --dport 55000 -j DNAT --to $STORAGE:22


# Libera acesso externo ao DNS
iptables -A FORWARD -p udp -s $HOST -d $DNS1 --dport 53 -j ACCEPT
iptables -A FORWARD -p udp -s $DNS1 -d $HOST --sport 53 -j ACCEPT
iptables -t nat -A PREROUTING -p udp -s $HOST -d $IP1 --dport 53 -j DNAT --to $DNS1:53

iptables -A FORWARD -p udp -s $HOST -d $DNS2 --dport 53 -j ACCEPT
iptables -A FORWARD -p udp -s $DNS2 -d $HOST --sport 53 -j ACCEPT
iptables -t nat -A PREROUTING -p udp -s $HOST -d $IP2 --dport 53 -j DNAT --to $DNS2:53

iptables -t nat -A POSTROUTING  -s $REDE -j MASQUERADE