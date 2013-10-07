#!/bin/bash

if [ `whoami` != 'root' ]
then
    echo "need root!"
    exit 1
fi

# Change this to your interface name, could it be eth* or p*p*.
IFACE="wlp4s0"
# Change this to your route addr.
ROUTE="192.168.1.1"
# Change this to your vpn **Server addr**
VPNHOST="221.239.126.9"
VPNADDR=`ifconfig ppp0|grep -P -o '(?<=inet )[0-9.]*'`
VPNROUTE=`ifconfig ppp0|grep -P -o '(?<=destination )[0-9.]*'`
echo "VPN-ADDR:"$VPNADDR
cmd="ip route add $VPNHOST via $ROUTE dev $IFACE"
echo $cmd
$cmd
cmd="route add default gw $VPNROUTE"
echo $cmd
$cmd
cmd="route del default gw $ROUTE"
echo $cmd
$cmd
# The net is the route's subnet. be careful.
route add -net 192.168.1.0/24 gw 192.168.1.1
echo -e 'nameserver 8.8.8.8\nsearch 8.8.4.4' > /etc/resolv.conf
