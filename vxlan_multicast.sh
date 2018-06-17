#配置多播MAC地址
ip maddr add 33:33:00:00:00:01 dev br0

#多播IP
#在支持 vxlan 的 Linux 主机上，可以创建多个多播或者单播的 vxlan interface，每个interface 是一个 vxlan tunnel 的 endpoint。比如在主机1上：

#创建多播 interface 1：
ip link add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth1 dstport 4789

#创建多播 interface 2：
ip link add vxlan2 type vxlan id 43 group 239.1.1.2 dev eth1 dstport 4790

#创建单播 interface 3：
ip link add vxlan2 type vxlan id 44 dev eth1 port 32768 61000 proxy ageing 300

#示例vxlan4090(239.1.1.1)--->br.4090 
brctl addbr br.4090
ip link add vxlan4090 type vxlan id 4090 group 239.1.1.1 dev eth0
ip link set vxlan4090 up
ip link set br.4090 up
brctl addif br.4090 vxlan4090
