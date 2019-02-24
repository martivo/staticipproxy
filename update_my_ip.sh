#!/bin/bash

REMOTEHOST=centos@0.0.0.0

myip=`curl -s ifconfig.co`

if [ "`echo $myip | awk -F"." '{print NF-1}'`" != "3" ]
then
  echo "Did not get IP. Got: $myip"
  exit 1
fi

curip=`cat ~/current_ip`

if [ "$myip" != "$curip" ]
then
  echo "Ip changed to $myip"
  ssh -p 2222 $REMOTEHOST "echo $myip > /root/current_ip"
  if [ $? -eq 0 ]
  then
    echo $myip > /root/current_ip
  else
    echo "Failed to update IP $myip on remote host"
  fi
fi
