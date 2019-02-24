# staticipproxy
Scripts that will turn your linux server into a proxy to another server that may have dynamic IP. Uses iptables.


I use this setup to rent a cheap VPS with a static IP to always redirect the traffic from there to my home server that has a dynamic IP. This could also be useful to setup a fake target that might help against DDOS attacks.
So I have two servers, one at home that has dynamic IP and a very cheap VPS that has a static IP.

#How it works
update_my_ip.sh - should be run on the "backend" server(the one with dynanmic IP).
Gets the external IP of the current host by polling ifconfig.co with curl.
If the IP has changed copies the IP to the "frontend" server (the one with static IP).
The IP is written to ~/current_ip on the "backend" host and to /root/current_ip on "frontend" host.


iptables_forward.sh - should be run on the "frontend" server(the one with static IP).
It checks if the IP in the /root/current_ip matches with the one in the iptables PREROUTING rule.
If the IP has changed or the rules are not there it applies the IPtables rules.

On the "frontend" server the port 2222 is not redirected to backend, but to local 22 port - this enables SSH access to the frontend server.



#Setup

First setup the backend server to detect your IP.
Place the update_my_ip.sh file where you can execute it. Not needed to run as root.
Make sure you can do a ssh connection to the "frontend" server from the "backend" user that runs the update_my_ip.sh script.
Change the value of REMOTEHOST in the update_my_ip.sh script to suit your server 

On the "frontend" machine you need to add line "net.ipv4.ip_forward = 1" to /etc/sysctl.conf or /etc/sysctl.d/99-custom.conf - depending on your distro. Then run sysctl -p.
You need to run the script as root or a user that has the privilege to make iptables rules.

First time the 2222 to 22 port might not exist, so you might want to create the file on the "frontend" machine by hand - it can even be a wrong ip.


First test the script out manually.
1) Run on "frontend"
2) Run on "backend"
3) Run on "frontend"

If you verify everything is working then add them to crons. I have used the following:

1) Backend (using crontab -e command)
*/15 * * * * /root/update_my_ip.sh

2) Frontend (using /etc/crontab)
* * * * * root /home/centos/iptables_forward.sh



