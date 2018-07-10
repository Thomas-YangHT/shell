#!/bin/bash
#VXLAN SHELL
HOST1_IP="192.168.31.253"
HOST2_IP="192.168.31.99"
VXIP1="10.10.10.1"
VXIP2="10.10.10.2"
DEV='br0'
VXLAN_ID=100
DSTPORT=4789
VXLAN_NAME="vxlan10"
HOST_IP=`ip addr show dev $DEV|grep -Po 'inet \K\w*.\w*.\w*.\w*'`
REMOTE_IP=''
[ "`echo $HOST_IP|grep $HOST1_IP`" ] && REMOTE_IP="$HOST2_IP" && VXIP="$VXIP1"
[ "`echo $HOST_IP|grep $HOST2_IP`" ] && REMOTE_IP="$HOST1_IP" && VXIP="$VXIP2"
echo "host_ip: $HOST_IP remote_ip:$REMOTE_IP">/root/br_vx.log

if [ "$REMOTE_IP" ]
then
   #创建网桥br-vx并使其up  
   brctl addbr br-vx  
   ip link set br-vx up  
   #增加一个类型为vxlan,vni-id为100的，名字为vxlan10的虚拟网卡，指明对端地址,出接口为本端的ethX 
   ip link add $VXLAN_NAME type vxlan id $VXLAN_ID remote $REMOTE_IP dstport $DSTPORT dev $DEV  
   ip link set $VXLAN_NAME up  
   #把vxlan10加入到网桥中  
   brctl addif br-vx $VXLAN_NAME  
   ifconfig br-vx $VXIP
fi

if [ ! -f "/etc/sysconfig/network-scripts/ifcfg-br-vx" ];then
cat >/etc/sysconfig/network-scripts/ifcfg-br-vx <<EOF
DEVICE=br-vx
STP=no
TYPE=Bridge
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=no
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=br-vx
UUID=
ONBOOT=yes
IPADDR=$VXIP               #这里的IP地址是网桥的IP地址，方便做DHCP
PREFIX=24
EOF
fi
