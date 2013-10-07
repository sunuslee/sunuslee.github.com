#!/bin/sh


SUNUS_IP='192.168.1.169'
VPN_ROUTE=`ifconfig ppp0|grep -o 'P-t-P:[0-9.]*'|tr -d 'P-t-P:'`
VPN_IP=`ifconfig ppp0|grep -o 'addr:[0-9.]*'|tr -d 'addr:'`
TMP_RULES_FILE='/tmp/TRF'
ROUTE_TABLE='sunusroute'
if [ "$VPN_ROUTE" = "" -o "$VPN_IP" = "" ]
then
  echo -e "\n*********\n"
  echo "No VPN-Connection"
  echo "Make sure your xl2tp is working"
  echo -e "\n*********\n"
  exit 1
fi

sed "s/PPP0-IP/$VPN_IP/" working-iptables-rule > $TMP_RULES_FILE
echo -e "\n*********\n"
echo "VPN-ROUTE:"$VPN_ROUTE
echo "VPN-ADDR:"$VPN_IP

ip route add default via $VPN_ROUTE dev ppp0 table $ROUTE_TABLE
ip rule add from $SUNUS_IP table $ROUTE_TABLE
ip route flush cache

echo "setting ip rules and route-policy successfully"
echo -e "\n*********\n"

echo -e "\n*********\n"
iptables-restore < $TMP_RULES_FILE
echo "setting iptables successfully"
echo -e "\n*********\n"

echo -e "\n*********\n"
echo "NOW SUNUS CAN USING THE VPN CONNECTING!"
echo -e "\n*********\n"
