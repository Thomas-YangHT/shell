# lvs-nat.sh 
#!/bin/bash（释棒/释伴）

iptables -F
iptables -X 
iptables -Z
#所有从192.168.1.0网络段服务器发给客户端的数据，都把源ip 都伪装成与客户端连接的路由器网关ip
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE
ipvsadm -C
# -A（声明一个虚拟主机)  -s（指定算法） wrr
ipvsadm -A -t 172.16.0.1:80 -s wrr
#（tcp:80 ip为172.16.0.1的虚拟主机接受请求）（转发给ip 192.168.1.2 端口tcp :80的服务器 ） -m（nat 模式） -w（指定加权值） 2 
ipvsadm -a -t 172.16.0.1:80 -r 192.168.1.2:80 -m -w 3
ipvsadm -a -t 172.16.0.1:80 -r 192.168.1.3:80 -m -w 3	
