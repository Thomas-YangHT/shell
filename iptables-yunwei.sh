cat <<EOF>/etc/sysconfig/iptables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [359:31532]
-A INPUT -i lo  -j ACCEPT
#below 2 lines defense DNS attack
#ÏÂÃæ2ÐÐ ¼ÙÈç·À»ðÇ½ÖØÆôÆð²»À´¾Í×¢ÊÍµô£¬±àÒë¹ýÄÚºË²»Ö§³ÖÄ£¿é¼ÓÔØ¡£ÄÚºËÀïÃæ²»Ö§³Ölength
#-I INPUT -p udp --sport 53 -m length --length 2077:65535 -j DROP
#-I INPUT -p tcp --sport 53 -j DROP
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -s 192.168.250.0/24 -j ACCEPT
-A INPUT -s 192.168.251.0/24 -j ACCEPT
-A INPUT -s 192.168.252.0/24 -j ACCEPT
-A INPUT -s 192.168.253.0/24 -j ACCEPT
-A INPUT -s 192.168.254.0/24 -j ACCEPT
-A INPUT -s 192.168.255.0/24 -j ACCEPT
-A INPUT -s 172.16.0.0/16 -p tcp --dport 22 -j ACCEPT
-A INPUT -s 172.16.0.0/16 -p tcp --dport 30022 -j ACCEPT
-A INPUT -s 172.16.0.11/16  -j ACCEPT
-A INPUT -s 10.0.0.0/8 -j ACCEPT
-A INPUT -p tcp -m tcp --sport 80 -j ACCEPT 
-A INPUT -p tcp -m tcp --sport 443 -j ACCEPT 
-A INPUT -p udp -m udp --sport 53 -j ACCEPT 
-A INPUT -p udp -m udp --sport 123 -j ACCEPT
-A INPUT -p icmp -j ACCEPT 
-A INPUT -j DROP
-A FORWARD -j DROP
COMMIT
EOF

mkdir /usr/libexec/iptables
#scp -P 30022 192.168.254.1:/etc/sysconfig/iptables /etc/sysconfig/iptables
scp -P 30022 192.168.254.1:/usr/libexec/iptables/iptables.init /usr/libexec/iptables/iptables.init
scp -P 30022 192.168.254.1:/usr/lib/systemd/system/iptables.service /usr/lib/systemd/system/iptables.service
ls /etc/sysconfig/iptables
systemctl restart iptables
systemctl daemon-reload
systemctl restart iptables
iptables -nvL
iptables -nvL -t nat
