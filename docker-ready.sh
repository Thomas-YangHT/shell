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

yum update docker-engine-17.05.0.ce docker-engine-selinux-17.05.0.ce
#yum install docker-engine-1.12.5 docker-engine-selinux-1.12.5

#设置docker

mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf << 'EOF'
[Service]
MountFlags=shared
EOF

#访问私有的Docker仓库
#编辑  /usr/lib/systemd/system/docker.service
#注意修改IP

#将本机eth0 ip 设为registry仓库IP，适用于单机安装kolla
IP="192.168.31.140"
#IP=`ip addr show dev eth0|grep -Po 'inet \K\w*.\w*.\w*.\w*'`
sed -i.ori "s#ExecStart=/usr/bin/dockerd#ExecStart=/usr/bin/dockerd --insecure-registry $IP:5000#" /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker

#1.13
DK_CONFIG="OPTIONS='--selinux-enabled -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 \
--add-registry=192.168.100.222:5000 \
--insecure-registry 192.168.100.222:5000 \
--log-driver=journald --signature-verification=false'"
echo $DK_CONFIG>>/etc/sysconfig/docker

#17.5
#此为设置单独的registry ip
IP="192.168.254.211"
OPTIONS="--selinux-enabled -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 --insecure-registry $IP:5000 --log-driver=journald --registry-mirror https://fvhsob7q.mirror.aliyuncs.com"
sed -i.ori "s#ExecStart=.*#ExecStart=/usr/bin/dockerd $OPTIONS#" /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker


#将kolla的镜相保存到私有镜相库示例：
#docker tag $1":"$2 localhost:4000/$1":"$2
#docker push localhost:4000/$1":"$2
docker run -d -v /opt/registry:/var/lib/registry -p 4000:5000 --restart=always --name registry registry:latest
docker images|grep kolla|awk '{print "docker tag "$1":ocata localhost:4000/"$1":ocata;docker push localhost:4000/"$1":ocata"}'|sh

docker images|grep -v none|sed 's#docker.io/##g'|awk 'NR>1{print "docker push "$1":"$2}'|sh

IMAGES=(`docker images |awk 'NR>1{print $1":"$2}'`)

for i in ${IMAGES[@]}
do
  j=`echo $i|sed 's#192.168.31.12:4000#192.168.31.140:5000#g'`
  docker tag $i $j
  docker push $j
done







