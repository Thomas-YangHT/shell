sh new-kvm-yunwei.sh "$1"
echo "pls set ip in mysql, and then press ENTER to continue..."
read
ssh 192.168.253.254 "curl 192.168.253.5/shell/set_ip-yunwei.sh|sh"
ssh 192.168.253.254 "cd /etc/yum.repos.d;mv docker.repo .."
ssh 192.168.253.254 "curl 192.168.253.5/shell/7-wget-hosts-iptables-repo.sh|sh"
ssh 192.168.253.254 "yum install nfs-utils -y;chmod +x /etc/rc.d/rc.local"
ssh 192.168.253.254 "echo 'mount -t nfs4 nfs.yunwei.edu:/ /opt;sleep 3;systemctl restart docker'>>/etc/rc.d/rc.local"
ssh 192.168.253.254 reboot
