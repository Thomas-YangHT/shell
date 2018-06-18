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
#yum install docker-engine-1.12.5-1 docker-engine-selinux-1.12.5-1

#设置docker

mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf << 'EOF'
[Service]
MountFlags=shared
EOF

#访问私有的Docker仓库
#编辑  /usr/lib/systemd/system/docker.service
#注意修改IP

IP="192.168.31.10"
#IP=`ip addr show dev eth0|grep -Po 'inet \K\w*.\w*.\w*.\w*'`
sed -i.ori "s#ExecStart=/usr/bin/dockerd#ExecStart=/usr/bin/dockerd --insecure-registry $IP:4000#" /usr/lib/systemd/system/docker.service

#17.5
IP="192.168.31.140"
OPTIONS="--selinux-enabled -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 --insecure-registry $IP:5000 --log-driver=journald --registry-mirror https://fvhsob7q.mirror.aliyuncs.com"
sed -i.ori "s#ExecStart=.*#ExecStart=/usr/bin/dockerd $OPTIONS#" /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker

#重启服务

systemctl daemon-reload
systemctl restart docker

#将kolla的镜相保存到私有镜相库示例：
#docker tag $1":"$2 localhost:4000/$1":"$2
#docker push localhost:4000/$1":"$2
docker run -d -v /opt/registry:/var/lib/registry -p 4000:5000 --restart=always --name registry registry:latest
docker images|grep kolla|awk '{print "docker tag "$1":ocata localhost:4000/"$1":ocata;docker push localhost:4000/"$1":ocata"}'|sh
