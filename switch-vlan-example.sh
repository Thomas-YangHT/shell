#网络环境初始化
#两台H3C S6800作为核心交换机，使用IRF 2.0横向虚拟化技术将两台设备虚拟化成一台；一台H3C S5600作为接入交换机，链路捆绑双上联到核心交换机；每台服务器使用两个电口，链路捆绑上连到接入交换机，捆绑的逻辑接口配置为trunk模式.在服务器端配置三个虚拟接口bond0.4001、bond0.4002、bond0.4003，分别用作OpenStack的管理网段接口、ceph集群的cluster网络接口、ceph集群的public网络接口，业务网络接口直接使用trunk模式配置的逻辑接口bond0;OpenStack使用基于vlan的flat网络模型部署，各个租户网络的网关均配置在核心交换机上。
#核心交换机S6800配置IRF 2.0及vlan
#核心交换机1
irf domain 1
irf member 1 priority 10
interface ten-gigabitEthernet 1/2/24
shutdown
quit
irf-port 1/2
port group interface ten-gigabitethernet 1/2/24
quit
interface ten-gigabitethernet 1/2/24
undo shutdown
quit
save
irf-port-configuration active

#核心交换机2
irf member 1 renumber 2
save
reboot
irf domain 1
interface ten-gigabitethernet 1/2/24
shutdown
quit
irf-port 2/1
port group interface ten-gigabitethernet 1/2/24
quit
interface ten-gigabitethernet 1/2/24
undo shutdown
save
irf-port-configuration active
#配置IRF 2.0基于lacp的分裂检测
bridge-aggregation1
port link-type trunk
port trunk permit vlan all
mad enable
quit
interface interface ten-gigabitEthernet 1/2/1
port link-mode bridge
port link-type trunk
port trunk permit vlan all
speed 1000
duplex full
port link-aggregation group 1
quit
interface interface ten-gigabitEthernet 1/2/1
port link-mode bridge
port link-type trunk
port trunk permit vlan all
speed 1000
duplex full
port link-aggregation group 1
quit
#配置vlan及网关
vlan 4001
description Management
vlan 4002
description Ceph_Cluster
vlan 4003
description Ceph_Data
interface Vlan-interface4001
ip address 10.7.1.254 255.255.255.0
interface Vlan-interface4002
ip address 10.7.2.254 255.255.255.0
interface Vlan-interface4003
ip address 10.7.3.254 255.255.255.0


#接入交换机配置网卡绑定及vlan、trunk
#配置vlan
vlan 4001
description Management
vlan 4002
description Ceph_Cluster
vlan 4003
description Ceph_Data
#配置到核心交换机的链路捆绑
link-aggregation group 1 mode static
interface GigabitEthernet0/1
port link-type trunk
port trunk permit vlan all
port link-aggregation group 1
interface GigabitEthernet0/2
port link-type trunk
port trunk permit vlan all
port link-aggregation group 1
#配置到服务器端的接口为trunk
interface GigabitEthernet0/3
port link-type trunk
port trunk permit vlan all
#所有服务器配置网卡绑定及trunk模式