# LVS DR
yum install ipvsadm  -y
VIP=172.16.254.246
PORT=80
RIP1=192.168.254.5
RIP2=192.168.254.6
ETH0=eth0
MODE='-g'
#-i TUN 模式;-g DR 模式;-m NAT 模式
METHOD='rr'
#rr：轮询 rr 算法就是将外部请求顺序轮流分配到集群中的 node 上，但不考虑每台 node 的负载情况。
#wrr：加权轮询 wrr 算法在 rr 算法的基础上会考察每台 node 的负载情况，并尝试让负较轻的 node 承担更多请求。
#lc：最少连接 算法可以让 LVS 尝试把新的请求交给当前连接数最少的 node ，直到此 node 连接数不再属于最少标准
#wlc：加权最少连接 wlc 算法也由权重的干预。LVS 会根据每台 node 的权重并综合连接数控制转发行为
#lblc：局部最少连接 算法会加上针对源请求 IP 地址的路由估算，并尝试把请求发送到与源请求 IP 路由最近的 node 上。此种方法一般用于远程或者是大规模的集群组
#lblcr：带有复制的局部最少连接算法 lblcr 算法是在 lblc 算法的基础上增加了一个 node 列表，先依据 lblc 算法计算出与源请求 IP 地址最近的一组 node ，然后在决定把请求发送到最近一组中的最近的一台 node 。若此 node 没有超载则将请求转发给这台 node, 如果超载则依据”最少连接”原则找到最少连接的 node 并将此 node 加入集群组中。并将请求转给此 node
#dh：目标地址散列算法 相当于随机
#sh：原地址散列算法 相当于随机

/sbin/ipvsadm -C
/sbin/ifconfig $ETH0:0 $VIP broadcast $VIP netmask 255.255.255.255 up 
#（给eno16777736网卡增加一个虚拟ip ）
/sbin/route add -host $VIP dev $ETH0:0  
#(添加一个虚拟主机路由：用于指定本机通过哪个设备可以连接到vip)

#添加一个虚拟服务并制定调度算法   -A 添加  -t IP与端口 -s 调度算法一共8种
#注意：端口一定要与后端服务器端口一一致，因为转发包只修改MAC地址，目标端口不会修改。
ipvsadm -A -t $VIP:$PORT -s $METHOD
#添加后端服务器
ipvsadm -a -t $VIP:$PORT -r $RIP1:$PORT $MODE -w 1
ipvsadm -a -t $VIP:$PORT -r $RIP2:$PORT $MODE -w 1

 