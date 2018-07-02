#配置网卡bond
#https://www.cnblogs.com/hukey/p/6224969.html
http://www.mamicode.com/info-detail-1738640.html

# cat ifcfg-em3
NAME="em3"
DEVICE="em3"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=Ethernet
NM_CONTROLLED=no
MASTER=bond0
SLAVE=yes
# cat ifcfg-em4
NAME="em4"
DEVICE="em4"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=Ethernet
NM_CONTROLLED=no
MASTER=bond0
SLAVE=yes
# cat ifcfg-bond0
NAME="bond0"
DEVICE="bond0"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=bond
BONDING_OPTS="mode=1 miimon=100"
NM_CONTROLLED=no


#配置trunk接口的vlan子接口
# cat ifcfg-bond0.4001
NAME="bond0.4001"
DEVICE="bond0.4001"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=bond
NM_CONTROLLED=no
VLAN=yes
IPADDR=10.7.1.1
NETMASK=255.255.255.0
GATEWAY=10.7.1.254
# cat ifcfg-bond0.4002
NAME="bond0.4002"
DEVICE="bond0.4002"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=bond
NM_CONTROLLED=no
VLAN=yes
IPADDR=10.7.2.1
NETMASK=255.255.255.0
# cat ifcfg-bond0.4003
NAME="bond0.4003"
DEVICE="bond0.4003"
ONBOOT=yes
NETBOOT=yes
IPV6INIT=no
BOOTPROTO=none
TYPE=bond
NM_CONTROLLED=no
VLAN=yes
IPADDR=10.7.3.1
NETMASK=255.255.255.0