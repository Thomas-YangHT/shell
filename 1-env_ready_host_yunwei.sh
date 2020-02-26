#物理机安装：CentOS-7-x86_64-Minimal-1511.iso
#注意启动修改initrd硬盘位置
#此脚本安装 KVM虚拟化环境，并做基本系统设置
#
#修改此主机名称
HOSTNAME=yunwei1
#修改IP为你的管理机，没有则忽略，注意不是此物理机的IP
IPADDR=172.16.254.1

#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
cd /etc/yum.repos.d; wget http://mirrors.163.com/.help/CentOS7-Base-163.repo
yum install -y epel-release wget
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

#SSHD禁掉DNS解析、网卡的名字改回ethX;
sed  -i  '/UseDNS/i UseDNS=no' /etc/ssh/sshd_config
sed -i.ori 's/rhgb/net.ifnames=0 biosdevname=0 rhgb/g' /boot/grup2/grub.conf
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
mkdir ~/.ssh;cd ~/.ssh;scp -P 30022 $IPADDR:/root/.ssh/id_rsa.pub .
cat id_rsa.pub >>authorized_keys


#
#/usr/sbin/iptables -t nat -A POSTROUTING  -o wlan0 -j MASQUERADE
