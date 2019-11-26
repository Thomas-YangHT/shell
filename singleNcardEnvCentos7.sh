#物理机安装：CentOS-7-x86_64-Minimal-1511.iso
#注意启动修改initrd硬盘位置
#此脚本安装 KVM虚拟化环境，并做基本系统设置
#
#修改此主机名称
HOSTNAME=ssll001
#修改IP为你的管理机，没有则忽略，注意不是此物理机的IP
#IPADDR=192.168.100.71

#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
cd /etc/yum.repos.d; wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
yum install -y epel-release wget
#yum update
yum install -y net-tools sysstat vim curl git chrony
yum install -y qemu-kvm libvirt virt-install bridge-utils 
yum install -y fabric ansible 
#yum install -y docker docker-compose
#yum install -y php php-mysql python-flask uwsgi uwsgi-plugin-python uwsgi-plugin-php MySQL-python
#yum install -y awstats smokeping perl-CGI     
#....  
#yum update
   
#配置：
systemctl stop firewalld
#systemctl stop NetworkManager
systemctl disable firewalld
#systemctl disable NetworkManager

#SSHD禁掉DNS解析、网卡的名字改回ethX;
sed  -i  '/UseDNS/i UseDNS=no' /etc/ssh/sshd_config
sed -i.ori 's/rhgb/net.ifnames=0 biosdevname=0 rhgb/g' /boot/grub2/grub.cfg
#使用EFI启动方式的情形：单挂载/boot/efi，grub.cfg位置变为：/boot/efi/EFI/centos/grub.cfg
#sed -i.ori 's/rhgb/net.ifnames=0 biosdevnam=0 rhgb/g' /boot/efi/EFI/centos/grub.cfg

#设置语言、字符集、时区、BASH提示符
echo 'export PS1="\[\e[32;40m\]\u@\h\[\e[35;40m\]\t\[\e[0m\]\w#"' >>/root/.bashrc
echo 'LANG="zh_CN.UTF-8"' >/etc/locale.conf
#echo 'LC_ALL="zh_CN.UTF-8"' >>/etc/locale.conf
echo 'LC_ALL="en_US.UTF-8"' >>/etc/locale.conf
ln -s  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#ntpdate xxx.xxx.xxx; clock -w

#关闭selinux、打开IPV4转发、NTP服务
sed -i.ori 's/enforcing/disabled/' /etc/selinux/config
sed -i.ori -e '$a\bindcmdaddress 127.0.0.1\nbindcmdaddress ::1\nlocal stratum 10\n' /etc/chrony.conf
sed -i.ori '$a\net.ipv4.ip_forward=1' /etc/sysctl.conf

#主机名修改
hostnamectl set-hostname $HOSTNAME

#设置SSH KEY登陆；
#mkdir ~/.ssh;cd ~/.ssh;scp -P 30022 $IPADDR:/root/.ssh/id_rsa.pub .
#cat id_rsa.pub >>authorized_keys


#
#/usr/sbin/iptables -t nat -A POSTROUTING  -o wlan0 -j MASQUERADE

#
registriesIP="192.168.100.71:5000"

#升级docker 17.06.2 
#yum upgrade https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-17.06.2.ce-1.el7.centos.x86_64.rpm
#yum upgrade http://download.yunwei.edu/software/docker-ce-17.06.2.ce-1.el7.centos.x86_64.rpm #（放到本地下载服务器更佳）
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-19.03.5-3.el7.x86_64.rpm
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-cli-19.03.5-3.el7.x86_64.rpm
yum install ./*rpm
#升级docker-compose 1.19.0 
curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
#curl -L http://download.yunwei.edu/software/docker-compose > /usr/local/bin/docker-compose #（放到本地下载服务器更佳）
chmod +x /usr/local/bin/docker-compose
docker-compose --version

#修改仓库地址
cat >/etc/docker/daemon.json <<EOF
{
"registry-mirrors": [ "https://fvhsob7q.mirror.aliyuncs.com","https://registry.docker-cn.com"],
"insecure-registries": [ "$registriesIP"]
}
EOF
systemctl restart docker
docker info

IP=192.168.100.71
GATE=192.168.100.1
DNS1=192.168.1.1
DNS2=223.5.5.5
rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-br1
TYPE=Bridge
BOOTPROTO=none
DEVICE=br1
ONBOOT=yes
IPADDR=$IP
GATEWAY=$GATE
DNS1=$DNS1
DNS2=$DNS2
EOF

cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-eth0
TYPE=Ethernet
BOOTPROTO=none
DEVICE=eth0
ONBOOT=yes
BRIDGE=br1
EOF

cat >networkbr1.xml <<EOF
<network>  
<name>br1</name>    
<forward mode="bridge" />  
<interface dev="br1" /> 
</network>  
EOF
virsh net-define networkbr1.xml 
virsh net-autostart br1
virsh net-start br1
virsh net-list --all
brctl show
