DIR="/export/download/centos"
SOURCE="rsync://mirrors.kernel.org/centos"

#http://mirrors.sohu.com/centos/
#http://mirrors.kernel.org
#http://rsync.mirrors.ustc.edu.cn
#http://mirrors.neusoft.edu.cn

#yum install -y createrepo
mkdir -p $DIR/7/{os,extra,updates}
#createrepo -pdo /usr/local/apache/htdocs/x86_64 $DIR/os
#createrepo -pdo /usr/local/apache/htdocs/extra  $DIR/extra
#createrepo -pdo /usr/local/apache/htdocs/update $DIR/updates
rsync -avrt --delete $SOURCE/7/extras  $DIR/7/extras
rsync -avrt --delete $SOURCE/7/os      $DIR/7/os
rsync -avrt --delete $SOURCE/7/updates $DIR/7/updates
rsync -avrt --delete $SOURCE/RPM-GPG-KEY-CentOS-7 $DIR
#createrepo --update /usr/local/apache/htdocs/centos/extra
