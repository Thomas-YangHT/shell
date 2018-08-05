# vim lvs_dr_rs.sh
#!/bin/bash
vip=172.16.254.246
vip2=172.16.254.247
ifconfig lo:0 $vip broadcast $vip netmask 255.255.255.255 up
route add -host $vip lo:0
ifconfig lo:0 $vip2 broadcast $vip netmask 255.255.255.255 up
route add -host $vip2 lo:0
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce