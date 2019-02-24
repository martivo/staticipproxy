#!/bin/bash
#Read the current IP, feel free to change the file location.
curip=`cat /home/centos/current_ip`

#Read the current PREROUTING rules to detect the current IP that traffic is being directed to.
chainrule=`iptables -L PREROUTING -t nat | grep "to:" | tail -1 | cut -d":" -f2`

#Check if IP has changed.
if [ "$chainrule" != "$curip" ]
then
echo "Updating chain due to new ip or missing rules"

#Flushes all rules
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
#This is how you can "skip" redirection of some ports - in this case prometheus node exporter is still allowed into the "frontend" machine
iptables -A PREROUTING -t nat -p tcp --dport 9100 -j ACCEPT
#Redirecting 2222 to 22 on this host. 
iptables -A PREROUTING -t nat -p tcp --dport 2222 -j REDIRECT --to-port 22
#Redirect all TCP traffic to the backend server
iptables -A PREROUTING -t nat -p tcp -j DNAT --to-destination $curip
#Redirect all UDP traffic to the backend server
iptables -A PREROUTING -t nat -p udp -j DNAT --to-destination $curip
#Change the source IP of the redirected packages so they would find their way back.
iptables -t nat -A POSTROUTING --out-interface eth0 -j MASQUERADE  
fi
