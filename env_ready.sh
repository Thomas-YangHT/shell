#物理机安装：CentOS-7-x86_64-Minimal-1511.iso
yum install -y epel-release wget
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum update
yum install -y net-tools sysstat vim curl git
yum install -y docker docker-compose
yum install -y qemu-kvm libvirt virt-install bridge-utils 
#yum install -y php php-mysql python-flask uwsgi uwsgi-plugin-python uwsgi-plugin-php MySQL-python
#yum install -y awstats smokeping perl-CGI     
yum install -y fabric ansible 
#....  
yum update
   
#配置：
systemctl stop firewalld
systemctl stop NetworkManager
systemctl disable firewalld
systemctl disable NetworkManager
sed  -i  '/UseDNS/i UseeDNS=no' /etc/ssh/sshd_config
sed -i.ori 's/rhgb/net.ifnames=0 biosdevnam=0 rhgb/g' /boot/grup2/grub.conf
echo 'export PS1=”\[\e[32;40m\]\u@\h\[\e[35;40m\]\t\[\e[0m\]\w#”' >>/root/.bashrc
echo 'LANG="zh_CN.UTF-8"' >/etc/locale.conf
echo 'LC_ALL="en_US.UTF-8"' >>/etc/locale.conf
ln -s  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#ntpdate xxx.xxx.xxx; clock -w

#网络 IP没法通用,需要单独修改,后续改成自动注册和修改IP
mkdir /etc/netbak
cp /etc/sysconfig/network-scripts/ifcfg-* /etc/netbak
cat >/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
BOOTPROTO=static
TYPE=Bridge
NM_CONTROLLED=no
IPADDR=192.168.30.10
NETMASK=255.255.255.0
GATEWAY=192.168.30.1
DNS1=192.168.31.1
DNS2=114.114.114.114
BOOTPROTO=none
DEVICE=eth0
NM_CONTROLLED=no
ONBOOT=yes
BRIDGE=br0
EOF

cat >/etc/sysconfig/network-scripts/ifcfg-br0 <<EOF
BOOTPROTO=none
DEVICE=eth0
NM_CONTROLLED=no
ONBOOT=yes
BRIDGE=br0
EOF

cat >/etc/sysconfig/network-scripts/ifcfg-eth1 <<EOF
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=eth1
DEVICE=eth1
ONBOOT=yes
UUID=`grep -Po 'UUID=\K.*' /etc/netbak/ifcfg-eth1`
HWADDR=`grep -Po 'HWADDR=\K.*' /etc/netbak/ifcfg-eth1`
DNS1=192.168.31.1
DNS2=114.114.114.114
IPADDR=192.168.31.10
PREFIX=24
GATEWAY=192.168.31.1
PROXY_METHOD=none
BROWSER_ONLY=no
EOF

systemctl restart network



