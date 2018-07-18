#!/bin/bash

#修改IP和网卡名再运行
rm -rf /etc/sysconfig/network-scripts/ifcfg-*
rm -rf /etc/sysconfig/network-scripts/route-*
IP=172.16.254.254
IP2=192.168.254.254
IP3=192.168.253.254
IP4=192.168.252.254
IP5=192.168.251.254
GATE=172.16.0.1
PREFIX=16
DNS1=172.16.254.211
DNS2=223.5.5.5
ETH1=eth0
ETH2=eth1
ETH3=eth2
ETH4=ens10
ETH5=ens11

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH1
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH1
ONBOOT=yes
IPADDR=$IP
PREFIX=$PREFIX
GATEWAY=$GATE
DNS1=$DNS1
DNS2=$DNS2
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH2
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH2
ONBOOT=yes
IPADDR=$IP2
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH3
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH3
ONBOOT=yes
IPADDR=$IP3
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH4
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH4
ONBOOT=yes
IPADDR=$IP4
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH5
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH5
ONBOOT=yes
IPADDR=$IP5
EOF