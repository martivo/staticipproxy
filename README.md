# staticipproxy
Scripts that will turn your linux server into a proxy to another linux/mac server that may have dynamic IP.

I use this setup to rent a cheap VPS with a static IP to always redirect the traffic from there to my home server that has a dynamic IP. 
So I have two servers, one at home that has dynamic IP and a very cheap VPS that has a static IP.
I will refer to the static IP VPS as "frontend" and the dynamic IP server as "backend".

## Why 
1) A tiny VPS is cheaper than static IP at home in my case.
2) My home connections to the world will still have a changing IP - harder to block or track you.
4) Changing of ISP or moving your server location is easier - you will always have the same static IP - no need to change DNS.
5) This is not a VPN - outgoing connections from the "backend"  show your current real IP and you get the maximum of your ISP speed. VPN tends to be slower - latency wise for sure.
6) Having powerful VPS might be very expensive - so you can offload the work to your own hardware without huge cost.
7) It can have a security effect against DDOS - they would first kill the tiny VPS server and not your home connection - your home IP is not advertised.
8) Dyndns and no-ip services do not allow for A level domains and updates are a lot slower.

## How it works
update_my_ip.sh - should be run on the "backend" server(the one with dynanmic IP).
Gets the external IP of the current host by polling ifconfig.co with curl.
If the IP has changed copies the IP to the "frontend" server (the one with static IP).
The IP is written to ~/current_ip on the "backend" host and to /home/centos/current_ip on "frontend" host.


iptables_forward.sh - should be run on the "frontend" server(the one with static IP).
It checks if the IP in the /root/current_ip matches with the one in the iptables PREROUTING rule.
If the IP has changed or the rules are not there it applies the IPtables rules.

On the "frontend" server the port 2222 is not redirected to backend, but to local 22 port - this enables SSH access to the frontend server.



## Setup

### Backend
First setup the backend server to detect your IP.
Place the update_my_ip.sh file where you can execute it. Not needed to run as root.
Make sure you can do a ssh connection to the "frontend" server from the "backend" user that runs the update_my_ip.sh script.
Change the value of REMOTEHOST in the update_my_ip.sh script to suit your server 

### Frontend
On the "frontend" machine you need to add line "net.ipv4.ip_forward = 1" to /etc/sysctl.conf or /etc/sysctl.d/99-custom.conf - depending on your distro. Then run sysctl -p.
You need to run the script as root or a user that has the privilege to make iptables rules.

First time the 2222 to 22 port might not exist, so you might want to create the file on the "frontend" machine by hand - it can even be a wrong ip.

### Trial run
First test the script out manually.
1) Run on "frontend"
2) Run on "backend"
3) Run on "frontend"

If you verify everything is working then add them to crons. I have used the following:
### Cron
1) Backend (using crontab -e command)
*/15 * * * * /root/update_my_ip.sh

2) Frontend (using /etc/crontab)
* * * * * root /home/centos/iptables_forward.sh



