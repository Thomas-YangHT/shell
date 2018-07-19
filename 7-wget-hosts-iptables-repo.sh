cat <<EOF>/etc/resolv.conf
nameserver  192.168.254.251
nameserver  223.5.5.5
EOF
mkdir /usr/libexec/iptables
wget -O /etc/hosts download.yunwei.edu/shell/hosts
wget -O /etc/sysconfig/iptables  download.yunwei.edu/shell/iptables
wget -O /usr/libexec/iptables/iptables.init  download.yunwei.edu/shell/iptables.init 
wget -O /usr/lib/systemd/system/iptables.service  download.yunwei.edu/shell/iptables.service
chmod +x /usr/libexec/iptables/iptables.init
systemctl daemon-reload
systemctl restart iptables
wget -O /etc/yum.repos.d/Centos7-Base-yunwei.repo    download.yunwei.edu/shell/Centos7-Base-yunwei.repo  
wget -O /etc/yum.repos.d/epel-yunwei.repo   download.yunwei.edu/shell/epel-yunwei.repo
wget -O /etc/yum.repos.d/rdo-release-yunwei.repo  download.yunwei.edu/shell/rdo-release-yunwei.repo
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud  download.yunwei.edu/shell/RPM-GPG-KEY-CentOS-SIG-Cloud
cd /etc/yum.repos.d/;mv epel.repo ..;mv CentOS-Base.repo ..;mv rdo-release.repo ..;
yum repolist
