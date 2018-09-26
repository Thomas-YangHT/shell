#开启registry&web服务于5000&5001端口
DNS="192.168.32.1"
REG_DIR="/mnt/registry"  #是默认放docker应用仓库的目录
DIR=" /opt/cmp_registry" #是放compose配置文件的目录
mkdir  $REG_DIR
mkdir  $DIR &&  cd $DIR

wget https://raw.githubusercontent.com/Thomas-YangHT/docker-compose/master/cmp_registry/docker-compose.yml
sed -i -e "s/192.168.100.222/$DNS/g" -e "s#/mnt/registry#$REG_DIR#g" docker-compose.yml
#注意修改: /mnt/registry是默认放docker应用仓库的目录
#          DNS：一般设为网关地址即可

wget  https://raw.githubusercontent.com/Thomas-YangHT/docker-compose/master/cmp_registry/config-srv.yml
wget  https://raw.githubusercontent.com/Thomas-YangHT/docker-compose/master/cmp_registry/config-web.yml
#下载配置文件

docker-compose up -d  && docker-compose logs
#启动registry:5000 & web:5001