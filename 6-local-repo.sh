#
DIR="/export/download/centos"
SOURCE="rsync://mirrors.kernel.org/centos"

#http://mirrors.sohu.com/centos/
#http://mirrors.kernel.org
#http://rsync.mirrors.ustc.edu.cn
#http://mirrors.neusoft.edu.cn

#yum install -y createrepo
mkdir -p $DIR/7/
#createrepo -pdo $DIR/os $DIR/os
#createrepo -pdo $DIR/extras  $DIR/extras
#createrepo -pdo $DIR/updates $DIR/updates
#createrepo -pdo $DIR/centosplus $DIR/centosplus
killall rsync
rsync -avrt --delete $SOURCE/7/extras  $DIR/7
rsync -avrt --delete $SOURCE/7/os      $DIR/7
rsync -avrt --delete $SOURCE/7/updates $DIR/7
rsync -avrt --delete $SOURCE/7/centosplus $DIR/7
rsync -avrt --delete $SOURCE/RPM-GPG-KEY-CentOS-7 $DIR
#createrepo --update $DIR/os
cd /export/download
reposync --repoid=openstack-ocata
reposync --repoid=epel
reposync --repoid=rdo-qemu-ev
createrepo epel
createrepo openstack-ocata
createrepo rdo-qemu-ev
