#kvm虚拟机安装：CentOS-7-x86_64-Minimal-1511.iso
#systemctl stop firewalld;systemctl disable firewalld;\
mkdir /mnt/kvm;chmod 777 /mnt;chmod 777 /mnt/kvm

#virt-install -n kvmbase2 -r 8192 \
--disk /mnt/kvm/centos-7.qcow2.kvm,format=qcow2,size=40 \
--network network=default \
--network bridge=br0 \
--network bridge=br1 \
--os-type=linux --os-variant=rhel7.2 \
--cdrom /mnt/software/CentOS-7-x86_64-Minimal-1511.iso \
--vnc --vncport=5910 --vnclisten=0.0.0.0
#===================================================
#eth0:default 192.168.122.0/24 dhcp
#eth1:br0 192.168.31.0/24 bridge
#eth2:br1 192.168.41.0/24 bridge
HOSTIP="192.168.31.253"    #hostip
GW="192.168.122.1"         #gateway
IP1="192.168.122.10"       #eth0
IP2="192.168.31.10"        #eth1
IP3="192.168.41.10"        #eth2
#分区 /var/lib/docker 35G xfs
umount /dev/vda2;mkfs -n ftype=1 -f /dev/vda2;mount /dev/vda2 /var/lib/docker
VDA="/dev/vda2 /var/lib/docker         xfs     defaults        0 0"
cp /etc/fstab /etc/fstab.bak
grep -v "/var/lib/docker" /etc/fstab.bak >/etc/fstab
echo $VDA >>/etc/fstab

sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/eth*
systemctl restart network
yum install epel-release -y;yum update

#yum remove -y PyYAML python-requests python-ipaddress python-urllib3
yum install -y python-pip
mkdir ~/.pip;cd ~/.pip
cat >pip.conf <<EOF
[global]
timeout = 60
index-url = http://pypi.douban.com/simple
trusted-host = pypi.douban.com
EOF
pip install -U pip
pip install PyYAML requests ipaddress urllib3==1.22 ansible fabric

yum install -y wget
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum install -y net-tools sysstat vim curl git chrony 
yum install -y python-devel libffi-devel gcc openssl-devel
yum update

   
#配置：
systemctl stop firewalld
systemctl disable firewalld
#systemctl stop NetworkManager
#systemctl disable NetworkManager
sed  -i  '/UseDNS/i UseDNS=no' /etc/ssh/sshd_config
sed -i.ori 's/rhgb/net.ifnames=0 biosdevnam=0 rhgb/g' /boot/grup2/grub.conf
echo 'export PS1="\[\e[32;40m\]\u@\h\[\e[35;40m\]\t\[\e[0m\]\w#"' >>/root/.bashrc
echo 'LANG="zh_CN.UTF-8"' >/etc/locale.conf
echo 'LC_ALL="en_US.UTF-8"' >>/etc/locale.conf
ln -s  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#serial port
sed -i.ori -e 's/"console"/"console serial"/g' \
-e '/GRUB_TERMINAL/a\GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"' \
-e '/swap rhgb/a\GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0,115200"' \
/etc/default/grub
/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
#ntpdate xxx.xxx.xxx; clock -w
sed -i.ori -e 's/server/#server/g' -e '/server 3./a\server 192.168.122.1 iburst' /etc/chrony.conf
sed -i.ori 's/enforcing/disabled/' /etc/selinux/config
echo kvmbase2 > /etc/hostname
hostname -f kvmbase2
#FORWARD
sed -i.ori '$a\net.ipv4.ip_forward=1' /etc/sysctl.conf
echo "
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
" >> /etc/sysctl.conf
sysctl -p
#SSH ID
mkdir /root/.ssh
cd /root/.ssh
mkdir ~/.ssh;cd ~/.ssh;scp $HOSTIP:/root/.ssh/id_rsa* .
cat id_rsa.pub >>authorized_keys



#网络 IP没法通用,需要单独修改,后续改成自动注册和修改IP
mkdir /etc/netbak
cp /etc/sysconfig/network-scripts/ifcfg-* /etc/netbak

cat >/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=eth0
DEVICE=eth0
ONBOOT=yes
UUID=`grep -Po 'UUID=\K.*' /etc/netbak/ifcfg-eth0`
HWADDR=`grep -Po 'HWADDR=\K.*' /etc/netbak/ifcfg-eth0`
DNS1=223.5.5.5
DNS2=114.114.114.114
IPADDR=$IP1
PREFIX=24
GATEWAY=$GW
PROXY_METHOD=none
BROWSER_ONLY=no
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
#DNS1=
DNS2=223.5.5.5
IPADDR=$IP2
PREFIX=24
#GATEWAY=
PROXY_METHOD=none
BROWSER_ONLY=no
EOF

cat >/etc/sysconfig/network-scripts/ifcfg-eth2 <<EOF
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=eth2
DEVICE=eth2
ONBOOT=yes
UUID=`grep -Po 'UUID=\K.*' /etc/netbak/ifcfg-eth2`
HWADDR=`grep -Po 'HWADDR=\K.*' /etc/netbak/ifcfg-eth2`
#DNS1=
DNS2=223.5.5.5
IPADDR=$IP3
PREFIX=24
#GATEWAY=
PROXY_METHOD=none
BROWSER_ONLY=no
EOF

systemctl restart network
systemctl restart chronyd
chronyc sourcestats -v

#设置repo

tee /etc/yum.repos.d/docker.repo << 'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

#安装Docker 17.05
yum install docker-engine-17.05.0.ce docker-engine-selinux-17.05.0.ce
systemctl restart docker
docker info

#设置docker

mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf << 'EOF'
[Service]
MountFlags=shared
EOF
#访问私有的Docker仓库

#编辑  /usr/lib/systemd/system/docker.service

#ExecStart=/usr/bin/dockerd
#改为：ExecStart=/usr/bin/dockerd --insecure-registry 192.168.27.10:4000  --mtu 1400
#IP="192.168.31.10"
IP=`ip addr show dev eth0|grep -Po 'inet \K\w*.\w*.\w*.\w*'`
sed -i.ori "s#ExecStart=/usr/bin/dockerd#ExecStart=/usr/bin/dockerd --insecure-registry $IP:4000#  --mtu 1400" /usr/lib/systemd/system/docker.service

#重启服务

systemctl daemon-reload
systemctl restart docker
