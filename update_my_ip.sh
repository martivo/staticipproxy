#!/bin/bash
#Change to the actual frtonend server <user>@<ip>
REMOTEHOST=centos@0.0.0.0

#This is how your current external IP is detected, feel free to change this part if you have another way of geting your external IP.
myip=`curl -s ifconfig.co`

#elaborate check to verify that it is an IP address we got.
if [ "`echo $myip | awk -F"." '{print NF-1}'`" != "3" ]
then
  echo "Did not get IP. Got: $myip"
  exit 1
fi

#The last IP that was sent as an update to remote hosst.
curip=`cat ~/current_ip`

if [ "$myip" != "$curip" ]
then
  echo "Ip changed to $myip"
  #Copy the new IP to frontend server.
  ssh -p 2222 $REMOTEHOST "echo $myip > /home/centos/current_ip"
  if [ $? -eq 0 ]
  then
    echo $myip > /root/current_ip
  else
    echo "Failed to update IP $myip on remote host"
  fi
fi
