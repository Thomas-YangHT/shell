IP="192.168.254.211"
OPTIONS="--selinux-enabled -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 --insecure-registry $IP:5000 --log-driver=journald --registry-mirror https://fvhsob7q.mirror.aliyuncs.com"
sed -i.ori "s#ExecStart=.*#ExecStart=/usr/bin/dockerd $OPTIONS#" /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker
docker info

cd /usr/loca/bin
wget 192.168.254.251:/software/docker-compose
chmod 755 docker-compose
docker-compose --version

