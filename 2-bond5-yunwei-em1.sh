#!/bin/bash
#创建一个名为bond0的链路接口
#修改IP和网卡名再运行
#eth0--->br1---->virt br1
#eth1/eth2/eth3--->bond0--->br0--->virt br0
#
cd /etc/sysconfig/network-scripts/
mkdir bak
cp ifcfg* bak/
rm -rf /etc/sysconfig/network-scripts/ifcfg-*
rm -rf /etc/sysconfig/network-scripts/route-*
IP=172.16.254.1
IP2=192.168.254.1
IP3=192.168.253.1
IP4=192.168.252.1
IP5=192.168.251.1
#IP6=10.20.0.1
GATE=172.16.0.1
DNS1=172.16.254.251
DNS2=223.5.5.5
#modify this if netcard is em*
ETH1=em1
ETH2=em2
ETH3=em3
ETH4=em4
MODE=6 #blance-tlb
#balance-rr(0)
#active-backup(1)
#balance-xor (2)
#broadcast (3)
#802.3ad (4)
#balance-tlb (5) 
#balance-alb (6)
#从数据库取得设置参数
func_GET(){
    FILENAME="/etc/sysconfig/network-scripts/ifcfg-em1"
    MYHOST="192.168.254.211"
    #UUID=`nmcli c|grep eth0|awk '{print $2}'`
    UUID=`grep -Po "UUID=\K.*" $FILENAME`
    MAC=`ifconfig em1|grep ether|awk '{print $2}'`
  
    sql="select set_hostname, set_ip, set_prefix, set_gwip, set_dns1 \
         from baseinfo \
         where mac=\"$MAC\""
    
    RESULTS=(`echo $sql|mysql -uyanght -D monitor -pyanght -h $MYHOST`)
    i=5
    #i表示设定项目数量，检查结果数据是否为5项(去除表头)
    if [ $((${#RESULTS[@]}/2)) = $i ];then
      echo 1
      SET_hostname=${RESULTS[$i]}
      SET_ip=${RESULTS[$i+1]}
      SET_prefix=${RESULTS[$i+2]}
      SET_gwip=${RESULTS[$i+3]}
      SET_dns1=${RESULTS[$i+4]}
      #add
      SUFFIX=`echo $SET_ip|grep -Po ".*\.\K.*"`
      IP=$SET_ip
      IP2="192.168.254.$SUFFIX"
      IP3="192.168.253.$SUFFIX"
      IP4="192.168.252.$SUFFIX"
      IP5="192.168.251.$SUFFIX"
      GATE=$SET_gwip
      DNS1=$SET_dns1
      echo "SUFFIX: $SUFFIX;$IP;$IP2;$IP3;$IP4;$IP5;$GATE;$DNS1"  
    else 
      echo 2
      return 2
    fi
}

func_GET
echo "dbdata:$SET_hostname;$SET_IP;$IP;$DNS1;$GATE"
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
 
cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-br1
TYPE=Bridge
BOOTPROTO=none
DEVICE=br1
ONBOOT=yes
IPADDR=$IP
GATEWAY=$GATE
DNS1=$DNS1
DNS2=$DNS2
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH1
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH1
ONBOOT=yes
BRIDGE=br1
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH2
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH2
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH3
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH3
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH4
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH4
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-br0 
TYPE=Bridge
DEVICE=br0
ONBOOT=yes
IPADDR=$IP2
IPADDR1=$IP3
IPADDR2=$IP4
IPADDR3=$IP5
IPADDR4=$IP6
PREFIX3=24
PREFIX4=24
#GATEWAY=$GATE
#DNS1=$DNS1
#DNS2=$DNS2
EOF

#systemctl restart network
#ping $GATE -c 1
#systemctl enable NetworkManager
#reboot
#check: speed 2000MB/s
# ethtool bond0
# brctl show
# ifconfig br0

#virsh br0 br1
cat >networkbr0.xml <<EOF
<network>  
<name>br0</name>    
<forward mode="bridge" />  
<interface dev="bond0" /> 
</network>  
EOF
virsh net-define networkbr0.xml 
virsh net-autostart br0
virsh net-start br0
virsh net-list --all
brctl show

cat >networkbr1.xml <<EOF
<network>  
<name>br1</name>    
<forward mode="bridge" />  
<interface dev="em1" /> 
</network>  
EOF
virsh net-define networkbr1.xml 
virsh net-autostart br1
virsh net-start br1
virsh net-list --all
brctl show


