#!/bin/bash
curip=`cat /home/centos/current_ip`

chainrule=`iptables -L PREROUTING -t nat | grep "to:" | tail -1 | cut -d":" -f2`

if [ "$chainrule" != "$curip" ]
then
echo "Updating chain due to new ip or missing rules"

iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -A PREROUTING -t nat -p tcp --dport 9100 -j ACCEPT
iptables -A PREROUTING -t nat -p tcp --dport 2222 -j REDIRECT --to-port 22
iptables -A PREROUTING -t nat -p tcp -j DNAT --to-destination $curip
iptables -A PREROUTING -t nat -p udp -j DNAT --to-destination $curip
iptables -t nat -A POSTROUTING --out-interface eth0 -j MASQUERADE  
fi
