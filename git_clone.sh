#
git clone https://github.com/Thomas-YangHT/shell.git

#1.13
DK_CONFIG="OPTIONS='--selinux-enabled -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 \
--add-registry=192.168.100.222:5000 \
--insecure-registry 192.168.100.222:5000 \
--log-driver=journald --signature-verification=false'"
echo $DK_CONFIG>>/etc/sysconfig/docker


#17.5
IP="192.168.31.140"
OPTIONS="--selinux-enabled -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 --insecure-registry $IP:5000 --log-driver=journald --registry-mirror https://fvhsob7q.mirror.aliyuncs.com"
sed -i.ori "s#ExecStart=.*#ExecStart=/usr/bin/dockerd $OPTIONS#" /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker