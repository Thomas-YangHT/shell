#物理机安装：CentOS-7-x86_64-Minimal-1511.iso
#注意启动修改initrd硬盘位置
#此脚本安装 KVM虚拟化环境，并做基本系统设置
#
yum install -y epel-release wget
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum update
yum install -y net-tools sysstat vim curl git chrony
yum install -y qemu-kvm libvirt virt-install bridge-utils 
yum install -y fabric ansible 
#yum install -y docker docker-compose
#yum install -y php php-mysql python-flask uwsgi uwsgi-plugin-python uwsgi-plugin-php MySQL-python
#yum install -y awstats smokeping perl-CGI     
#....  
yum update
   
#配置：
systemctl stop firewalld
#systemctl stop NetworkManager
systemctl disable firewalld
#systemctl disable NetworkManager
#设置语言、字符集、时区、SSHD禁掉DNS解析、网卡的名字改回ethX;
sed  -i  '/UseDNS/i UseDNS=no' /etc/ssh/sshd_config
#sed -i.ori 's/rhgb/net.ifnames=0 biosdevnam=0 rhgb/g' /boot/grup2/grub.conf
#单挂载/boot/efi的情况，grub.cfg位置变为：/boot/efi/EFI/centos/grub.cfg
sed -i.ori 's/rhgb/net.ifnames=0 biosdevnam=0 rhgb/g' /boot/efi/EFI/centos/grub.cfg
echo 'export PS1="\[\e[32;40m\]\u@\h\[\e[35;40m\]\t\[\e[0m\]\w#"' >>/root/.bashrc
echo 'LANG="zh_CN.UTF-8"' >/etc/locale.conf
echo 'LC_ALL="zh_CN.UTF-8"' >>/etc/locale.conf
#echo 'LC_ALL="en_US.UTF-8"' >>/etc/locale.conf
ln -s  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#ntpdate xxx.xxx.xxx; clock -w
#关闭selinux、打开IPV4转发、NTP服务
sed -i.ori 's/enforcing/disabled/' /etc/selinux/config
sed -i.ori -e '$a\bindcmdaddress 127.0.0.1\nbindcmdaddress ::1\nlocal stratum 10\n' /etc/chrony.conf
sed -i.ori '$a\net.ipv4.ip_forward=1' /etc/sysctl.conf
#修改IP为你的登陆主机，没有则忽略
mkdir ~/.ssh;cd ~/.ssh;scp 192.168.31.140:/root/.ssh/id_rsa* .
cat id_rsa.pub >>authorized_keys

#网络 IP没法通用,需要单独修改,后续改成自动注册和修改IP
mkdir /etc/netbak
cp /etc/sysconfig/network-scripts/ifcfg-* /etc/netbak
cat >/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
BOOTPROTO=none
DEVICE=eth0
NM_CONTROLLED=no
ONBOOT=yes
BRIDGE=br0
EOF

cat >/etc/sysconfig/network-scripts/ifcfg-br0 <<EOF
STP=no
TYPE=Bridge
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
IPADDR=192.168.31.253
PREFIX=24
#DNS1=192.168.31.254
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV4_DNS_PRIORITY=100
IPV6INIT=yes
IPV6_AUTOCONF=no
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
IPV6_DNS_PRIORITY=100
NAME=br0
DEVICE=br0
ONBOOT=yes
#GATEWAY=192.168.31.254
NM_CONTROLLED=no
EOF


systemctl restart network

cat >networkbr0.xml <<EOF
<network>  
<name>br0</name>    
<forward mode="bridge" />  
<interface dev="eth0" /> 
</network>  
EOF
virsh net-define networkbr0.xml 
virsh net-autostart br0
virsh net-start br0
virsh net-list --all
brctl show
#
/usr/sbin/iptables -t nat -A POSTROUTING  -o wlan0 -j MASQUERADE
