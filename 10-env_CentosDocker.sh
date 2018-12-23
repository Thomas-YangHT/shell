#kvm虚拟机安装：CentOS-7-x86_64-Minimal-1511.iso

#分区 /var/lib/docker 30G xfs
umount /dev/vda3;sleep 2 
mkfs -t xfs -f -n ftype=1 /dev/vda3 && \
mount /dev/vda3 /var/lib/docker && \
VDA="/dev/vda3 /var/lib/docker         xfs     defaults        0 0" && \
cp -f /etc/fstab /etc/fstab.bak && \
grep -v "/var/lib/docker" /etc/fstab.bak|grep -v "swap" >/etc/fstab && \
echo $VDA >>/etc/fstab 
swapoff -a

#network
HOSTNAME=base
DNS1=192.168.31.140
IP=192.168.31.11
GW=
hostnamectl set-hostname $HOSTNAME
sed -i 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-eth*
echo """
nameserver $DNS1
nameserver 223.5.5.5
nameserver 114.114.114.114
""">/etc/resolv.conf
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
UUID=
HWADDR=`ip a show dev eth0|grep -Po "ether \K\w+:\w+:\w+:\w+:\w+:\w+"`
DNS1=$DNS1
DNS2=223.5.5.5
IPADDR=$IP
PREFIX=24
GATEWAY=$GW
PROXY_METHOD=none
BROWSER_ONLY=no
EOF
cat >/etc/sysconfig/network-scripts/ifcfg-eth1 <<EOF
TYPE=Ethernet
BOOTPROTO=DHCP
NAME=eth1
DEVICE=eth1
ONBOOT=yes
EOF

systemctl restart network

#yum
#yum install epel-release -y
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#if have internal yum repo, set_local_repo.sh, Example:
cd /etc/yum.repos.d/;mv * .. -f 
curl -o /etc/yum.repos.d/Centos7-Base-yunwei.repo    192.168.31.253/config/CentOS-Base-yunwei.repo && \
curl -o /etc/yum.repos.d/epel-yunwei.repo   192.168.31.253/config/epel-yunwei.repo && \
curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7  192.168.31.253/config/RPM-GPG-KEY-EPEL-7
#curl -o /etc/yum.repos.d/rdo-release-yunwei.repo  192.168.31.253/config/rdo-release-yunwei.repo
#curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud  192.168.31.253/config/RPM-GPG-KEY-CentOS-SIG-Cloud
yum repolist
yum remove -y PyYAML python-requests python-ipaddress python-urllib3
yum install -y wget net-tools sysstat vim curl git chrony ntpdate \
       python-pip socat ebtables iptables-service ipvsadm
#python-devel libffi-devel gcc openssl-devel \
yum update -y

#pip
mkdir ~/.pip;cd ~/.pip
cat >pip.conf <<EOF
[global]
timeout = 60
index-url = http://pypi.douban.com/simple
trusted-host = pypi.douban.com
EOF
pip install -U pip
pip install PyYAML requests ipaddress urllib3==1.22 ansible fabric

#sys 配置：
systemctl stop firewalld
systemctl disable firewalld
grep UseDNS=no  /etc/ssh/sshd_config
[ $? != 0 ] && sed  -i  '/UseDNS/i UseDNS=no' /etc/ssh/sshd_config
#serial port console
grep serial /etc/default/grub
[ $? != 0 ] && sed -i.ori -e 's/"console"/"console serial"/g' \
-e '/GRUB_TERMINAL/a\GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"' \
-e '/GRUB_TERMINAL/a\GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0,115200"' \
/etc/default/grub && \
/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
grep net.ifnames=0 /boot/grub2/grub.cfg
[ $? != 0 ] &&  sed -i.ori 's/rhgb/net.ifnames=0 biosdevnam=0 rhgb/g' /boot/grub2/grub.cfg
echo 'export PS1="\[\e[32;40m\]\u@\h\[\e[35;40m\]\t\[\e[0m\]\w#"' >>/root/.bashrc
echo 'LANG="zh_CN.UTF-8"' >/etc/locale.conf
echo 'LC_ALL="en_US.UTF-8"' >>/etc/locale.conf
rm /etc/localtime -f
ln -s  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#ntpdate $NTP_SERVER; clock -w
CHRONY_SRV=192.168.122.1
grep $CHRONY_SRV /etc/chrony.conf
[ $? != 0 ] && sed -i.ori -e 's/server/#server/g' -e "/server 3./a\server $CHRONY_SRV iburst" /etc/chrony.conf && \
systemctl restart chronyd
chronyc sourcestats -v

#selinux
sed -i.ori 's/enforcing/disabled/' /etc/selinux/config

#FORWARD & bridge
echo "
vm.swappiness = 0
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
" > /etc/sysctl.conf
sed -i.ori '$a\net.ipv4.ip_forward=1' /etc/sysctl.conf
sysctl -p

#SSH ID
SSH_AUTHKEY_URL=http://192.168.31.253/config/auth-key
mkdir /root/.ssh
cd /root/.ssh
mkdir ~/.ssh;cd ~/.ssh;
wget -O auth-key  $SSH_AUTHKEY_URL && \
cat auth-key >authorized_keys && \
echo "">>authorized_keys


#安装Docker 18.09
#DURL=https://download.docker.com/linux/centos/7/x86_64/stable/Packages/
DURL=http://192.168.31.253/software/
S1=${DURL}containerd.io-1.2.0-3.el7.x86_64.rpm
S2=${DURL}docker-ce-18.09.0-3.el7.x86_64.rpm
S3=${DURL}docker-ce-cli-18.09.0-3.el7.x86_64.rpm
yum install -y $S1 $S2 $S3

#设置docker
mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf << 'EOF'
[Service]
MountFlags=shared
EOF
sed -i "13i ExecStartPost=/usr/sbin/iptables -P FORWARD ACCEPT" /usr/lib/systemd/system/docker.service

#访问私有的Docker仓库
DOCK_REGISTRY="192.168.31.140:5000"
mkdir /etc/docker
tee /etc/docker/daemon.json <<EOF
{
"registry-mirrors": [ "https://registry.docker-cn.com"],
"insecure-registries": [ "$DOCK_REGISTRY","192.168.100.222:5000"]
}
EOF
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
docker info

#kernel upgrade
KURL=http://192.168.31.253/software/
KERNEL=${KURL}kernel-ml-4.18.12-1.el7.elrepo.x86_64.rpm
KERNEL_DEVEL=${KURL}kernel-ml-devel-4.18.12-1.el7.elrepo.x86_64.rpm
yum install -y $KERNEL $KERNEL_DEVEL
#rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm && \
#yum --enablerepo=elrepo-kernel install kernel-ml-devel kernel-ml -y
grub2-set-default 0

#ip_vs
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
ipvs_modules="ip_vs ip_vs_lc ip_vs_wlc ip_vs_rr ip_vs_wrr ip_vs_lblc ip_vs_lblcr ip_vs_dh ip_vs_sh ip_vs_fo ip_vs_nq ip_vs_sed ip_vs_ftp nf_conntrack"
for kernel_module in \${ipvs_modules}; do
 /sbin/modinfo -F filename \${kernel_module} > /dev/null 2>&1
 if [ $? -eq 0 ]; then
 /sbin/modprobe \${kernel_module}
 fi
done
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep ip_vs

