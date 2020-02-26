#kvm虚拟机安装：CentOS-7-x86_64-Minimal-1511.iso

#1.分区 /var/lib/docker 30G xfs用ftype=1重新格式化以适应docker overlay需要
umount /dev/vda3;sleep 2 
mkfs -t xfs -f -n ftype=1 /dev/vda3 && \
mount /dev/vda3 /var/lib/docker && \
VDA="/dev/vda3 /var/lib/docker         xfs     defaults        0 0" && \
cp -f /etc/fstab /etc/fstab.bak && \
grep -v "/var/lib/docker" /etc/fstab.bak|grep -v "swap" >/etc/fstab && \
echo $VDA >>/etc/fstab 
swapoff -a

#2.network两块网卡，一个接br0虚交换上配静态IP，一个接default默认虚交换上配DHCP
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
#eth1
cat >/etc/sysconfig/network-scripts/ifcfg-eth1 <<EOF
TYPE=Ethernet
BOOTPROTO=DHCP
NAME=eth1
DEVICE=eth1
ONBOOT=yes
EOF
systemctl restart network

#3.yum我使用内部repo,请根据实际情况修改，或改为外部yum源
#===External repo===
#yum install epel-release -y
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#===External repo===
#------if have internal yum repo, set_local_repo.sh, Example:
cd /etc/yum.repos.d/;mv * .. -f 
curl -o /etc/yum.repos.d/Centos7-Base-yunwei.repo    192.168.31.253/config/CentOS-Base-yunwei.repo && \
curl -o /etc/yum.repos.d/epel-yunwei.repo   192.168.31.253/config/epel-yunwei.repo && \
curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7  192.168.31.253/config/RPM-GPG-KEY-EPEL-7
#curl -o /etc/yum.repos.d/rdo-release-yunwei.repo  192.168.31.253/config/rdo-release-yunwei.repo
#curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud  192.168.31.253/config/RPM-GPG-KEY-CentOS-SIG-Cloud
#------internal yum repo-----#
yum repolist
yum remove -y PyYAML python-requests python-ipaddress python-urllib3
yum install -y wget net-tools sysstat vim curl git chrony ntpdate \
      python-pip socat ebtables iptables-service ipvsadm
#python-devel libffi-devel gcc openssl-devel \
yum update -y

#4.pip配置
mkdir ~/.pip;cd ~/.pip
cat >pip.conf <<EOF
[global]
timeout = 60
index-url = http://pypi.douban.com/simple
trusted-host = pypi.douban.com
EOF
pip install -U pip
pip install PyYAML requests ipaddress urllib3==1.22 ansible fabric

#5.firewalld 关闭：
systemctl stop firewalld
systemctl disable firewalld

#6.SSHD不使用DNS反查
grep UseDNS=no  /etc/ssh/sshd_config
[ $? != 0 ] && sed  -i  '/UseDNS/i UseDNS=no' /etc/ssh/sshd_config

#7.serial port console
grep serial /etc/default/grub
[ $? != 0 ] && sed -i.ori -e 's/"console"/"console serial"/g' \
-e '/GRUB_TERMINAL/a\GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"' \
-e '/GRUB_TERMINAL/a\GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0,115200"' \
/etc/default/grub && \
/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg

#8.ethX网卡名
grep net.ifnames=0 /boot/grub2/grub.cfg
[ $? != 0 ] &&  sed -i.ori 's/rhgb/net.ifnames=0 biosdevnam=0 rhgb/g' /boot/grub2/grub.cfg
<<<<<<< HEAD

#9.BASH提示符
echo 'export PS1="\[\e[32;40m\]\u@\h\[\e[35;40m\]\t\[\e[0m\]\w#"' >>/root/.bashrc

#10.语言字符集
=======
echo 'export PS1="\[\e[34;40m\]\u@\h\[\e[35;40m\]\t\[\e[0m\]\w#"' >>/root/.bashrc
##颜色
#30  40 黑色
#31  41 红色
#32  42 绿色
#33  43 黄色
#34  44 蓝色
#35  45 紫红色
#36  46 青蓝色
#37  47 白色
#PS1=’[\e[32;40m] [[\u@\h \w \t]$ [\e[0m]’
#PS1="[\e[37;40m][[\e[32;40m]\u[\e[37;40m]@\h [\e[36;40m]\w[\e[0m]]\$ "
#PS1="[\e[37;40m][[\e[32;40m]\u[\e[37;40m]@[\e[35;40m]\h[\e[0m] [\e[36;40m]\w[\e[0m]]\$ "

>>>>>>> 6cd6a497eb4369e5117eb0efa290e24b9730bb65
echo 'LANG="zh_CN.UTF-8"' >/etc/locale.conf
echo 'LC_ALL="en_US.UTF-8"' >>/etc/locale.conf

#11.时区
rm /etc/localtime -f
ln -s  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#12.时间同步，请根据自身实际修改IP
#ntpdate $NTP_SERVER; clock -w
CHRONY_SRV=192.168.122.1
grep $CHRONY_SRV /etc/chrony.conf
[ $? != 0 ] && sed -i.ori -e 's/server/#server/g' -e "/server 3./a\server $CHRONY_SRV iburst" /etc/chrony.conf && \
systemctl restart chronyd
chronyc sourcestats -v

#13.selinux
sed -i.ori 's/enforcing/disabled/' /etc/selinux/config

#14.FORWARD & bridge
echo "
vm.swappiness = 0
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
" > /etc/sysctl.conf
sed -i.ori '$a\net.ipv4.ip_forward=1' /etc/sysctl.conf
sysctl -p

#15.SSH ID，内部下载地址请修改
SSH_AUTHKEY_URL=http://192.168.31.253/config/auth-key
mkdir /root/.ssh
cd /root/.ssh
mkdir ~/.ssh;cd ~/.ssh;
wget -O auth-key  $SSH_AUTHKEY_URL && \
cat auth-key >authorized_keys && \
echo "">>authorized_keys

#16.安装Docker 18.09，装了最新版docker，k8s只测试到18.06，实测是不影响安装k8s
#DURL=https://download.docker.com/linux/centos/7/x86_64/stable/Packages/
#内部的下载，请根据实际情况修改或用上面的外部链接
DURL=http://192.168.31.253/software/
S1=${DURL}containerd.io-1.2.0-3.el7.x86_64.rpm
S2=${DURL}docker-ce-18.09.0-3.el7.x86_64.rpm
S3=${DURL}docker-ce-cli-18.09.0-3.el7.x86_64.rpm
yum install -y $S1 $S2 $S3

#17.设置docker
mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf << 'EOF'
[Service]
MountFlags=shared
EOF
#这句似乎没有用，新版的docker已经是accept的了
sed -i "13i ExecStartPost=/usr/sbin/iptables -P FORWARD ACCEPT" /usr/lib/systemd/system/docker.service

#18.访问私有的Docker仓库
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

#19.kernel upgrade
KURL=http://192.168.31.253/software/
KERNEL=${KURL}kernel-ml-4.18.12-1.el7.elrepo.x86_64.rpm
KERNEL_DEVEL=${KURL}kernel-ml-devel-4.18.12-1.el7.elrepo.x86_64.rpm
yum install -y $KERNEL $KERNEL_DEVEL
#rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm && \
#yum --enablerepo=elrepo-kernel install kernel-ml-devel kernel-ml -y
grub2-set-default 0

#20.ip_vs
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

#END.数了数，大小20+项修改

