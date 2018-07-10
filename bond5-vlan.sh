#!/bin/bash
#创建一个名为bond0的链路接口
#修改IP和网卡名再运行
IP=172.16.254.1
IP2=192.168.254.1
IP3=192.168.253.1
IP4=192.168.252.1
IP5=10.20.0.1
GATE=172.16.0.1
DNS1=172.16.254.254
DNS2=223.5.5.5
ETH1=eth1
ETH2=eth2
MODE=5 #blance-tlb
#balance-rr(0)
#active-backup(1)
#balance-xor (2)
#broadcast (3)
#802.3ad (4)
#balance-tlb (5) 
#balance-alb (6)

modprobe bonding
cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
TYPE=Bond
NAME=bond0
BONDING_MASTER=yes
BOOTPROTO=static
USERCTL=no
ONBOOT=yes
#IPADDR=$IP
#PREFIX=24
#GATEWAY=$GATE
BONDING_OPTS="mode=$MODE miimon=100"
BRIDGE=br0
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH1
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF
cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH2
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH2
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-br0 
TYPE=Bridge
DEVICE=br0
ONBOOT=yes
IPADDR=$IP
GATEWAY=$GATE
DNS1=$DNS1
DNS2=$DNS2
EOF


#配置trunk接口的vlan子接口
cd /etc/sysconfig/network-scripts
cat <<EOF>ifcfg-bond0.4001
NAME="bond0.4001"
DEVICE="bond0.4001"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=bond
NM_CONTROLLED=no
VLAN=yes
IPADDR=$IP2
NETMASK=255.255.255.0
GATEWAY=
BRIDGE=br1
EOF
cat <<EOF>ifcfg-bond0.4002
NAME="bond0.4002"
DEVICE="bond0.4002"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=bond
NM_CONTROLLED=no
VLAN=yes
IPADDR=$IP3
NETMASK=255.255.255.0
BRIDGE=br2
EOF
cat <<EOF>ifcfg-bond0.4003
NAME="bond0.4003"
DEVICE="bond0.4003"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=bond
NM_CONTROLLED=no
VLAN=yes
IPADDR=$IP4
NETMASK=255.255.255.0
BRIDGE=br3
EOF
cat <<EOF>ifcfg-bond0.4004
NAME="bond0.4004"
DEVICE="bond0.4004"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=bond
NM_CONTROLLED=no
VLAN=yes
IPADDR=$IP5
NETMASK=255.255.255.0
BRIDGE=br4
EOF

#bridge 1234
cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-br1 
TYPE=Bridge
DEVICE=br1
ONBOOT=yes
IPADDR=
GATEWAY=
DNS1=
DNS2=
EOF


cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-br2 
TYPE=Bridge
DEVICE=br2
ONBOOT=yes
IPADDR=
GATEWAY=
DNS1=
DNS2=
EOF


cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-br3
TYPE=Bridge
DEVICE=br3
ONBOOT=yes
IPADDR=
GATEWAY=
DNS1=
DNS2=
EOF


cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-br4
TYPE=Bridge
DEVICE=br4
ONBOOT=yes
IPADDR=
GATEWAY=
DNS1=
DNS2=
EOF

#systemctl restart network
#ping $GATE -c 1
reboot
#check: speed 2000MB/s
# ethtool bond0
# brctl show
# ifconfig br0
