#!/bin/bash

trap 'echo "$BASH_COMMAND";read' DEBUG

host1="Server-1"
host2="Server-2" # Hostname nods in the group

ip0="192.168.137.0/24" # Default network /etc/network/interafces
ip="192.168.137.1" # Default gateway
ip1="192.168.137.101" # Default cluster VIP
ip2="192.168.137.102/24"
ip3="192.168.137.103/24"
#ip4=192.168.137.104/24
ip5="192.168.137.105/24"
mac="ifconfig | grep -i ethernet | awk '{print $2}'" # Default MAC-address
mac0="3c:ec:ef:20:cd:85" # New master MAC-address
mac1="3c:ec:ef:20:cd:86" # New slave1 MAC-address
mac2="3c:ec:ef:20:cd:87" # New slave2 MAC-addres

logWrite()
{
  echo "$@"
  logger "$@"
}

CheckCluster()
{
  IFS=/;
  ip_check0=$(sudo ifconfig | grep -i 'inet' | awk '{print $2}')
  if [[ ${ip_check0} = ${ip1} ]];
  then
    make_master
  else
    make_slave
  fi
}

make_master()
{
  ip_check1=$(ip addr | grep -i 'inet' | awk '{print $2}')
  if [[ ${ip_check1} =~ ${ip5} ]];
  then
    logWrite "File exist"
  else
    ipadd5
  fi
}
ipadd5()
{
  if [ $HOSTNAME = $host1 ];
  then
  ip addr add $ip5 dev bond0:1
  elif [ $HOSTNAME = $host2 ];
  then
  ip addr add $ip5 dev bond1:1
  else
  logWrite "ERROR. Unknown host or incorrect function in ipaddr5"
  exit 1
  fi
}

ip_check2=$(ip route | grep default | awk '{print $3}')
  if  [[ ${ipcheck2} = ${ip} ]]
  then
    delroute
  else
    logWrite "File not found"
  fi

delroute()
{
  ip route del default via $ip
  if [ $? -eq 0 ];
  then
    logWrite "OK"
  else
    logWrite "ERROR. Default route not deleted"
    exit 2
  fi
}

  ip_check3=$(ip route | grep "$ip0" | awk '{print $9}')
  if  [[ ${ip_check3} = ${ip2} || ${ip_check3} = ${ip3} ]]
  then
    delroute2
  else
    logWrite "File not found"
  fi

delroute2()
{
  if [ $HOSTNAME = $host1 ];
  then
  ip route del $ip0 dev bond0 proto kernel scope link src $ip2 #192.168.137.102
  elif [ $HOSTNAME = $host2 ];
  then
  ip route del $ip0 dev bond1 proto kernel scope link src $ip3 #192.168.137.103
  else
    logWrite "ERROR. Unknown host"
    exit 3
  fi
}

  if  [[ ${ip_check3} =~ ${ip5} ]];
  then
  addroute
  else
  logWrite "File exist"
  fi

addroute()
{
  if [ $HOSTNAME = $host1 ];
  then
  ip route add $ip0 dev bond0 proto kernel scope link src $ip5 #192.168.137.105
  elif [ $HOSTNAME = $host2 ];
  then
  ip route add $ip0 dev bond1 proto kernel scope link src $ip5 #192.168.137.105
  else
    logWrite "ERROR. Unknown host"
    exit 4
  fi
}

  mac_check=$(ifconfig | grep -i 'ethernet' | awk '{print $2}')
  if [[ ${mac_check} = ${mac0} ]]
  then
  logWrite "File exist"
  else
  setmac
  fi

setmac()
{
  if [ $HOSTNAME = $host1 ];
  then
  ip link set dev bond0 address $mac0
  elif [ $HOSTNAME = $host2 ];
  then
  ip link set dev bond1 address $mac0
  else
    logWrite "ERROR. Unknown host"
    exit 5
  fi
}

make_slave()
{
echo "Slave"
}

logger "$0 $@"

exit 6

case $1 in
  "master")
    make_master
  ;;
  "backup")
    make_slave
  ;;
  "auto")
    CheckCluster
  ;;
*)  

echo "Usage ${0##*/} {master|backup|check}"
;;
esac
exit 0
