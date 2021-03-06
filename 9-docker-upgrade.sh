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