#准备目录和docker-compose文件、nginx配置文件；
DIR=" /opt/cmp_nginx_download";   mkdir  $DIR &&  cd $DIR

wget https://raw.githubusercontent.com/Thomas-YangHT/docker-compose/master/ngx_download/docker-compose.yml
#注意compose文件做相应修改

wget  https://raw.githubusercontent.com/Thomas-YangHT/docker-compose/master/ngx_download/download.yunwei.edu.conf
#注意修改conf文件中是域名以适应你的情况

docker-compose up -d  && docker-compose logs
#使用docker-compose启动nginx服务，默认下载路径：/export/download