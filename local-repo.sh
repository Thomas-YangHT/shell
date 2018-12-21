#!/usr/bin/bash
#
#For Create local  yum repo resources
#                    by Thomas yang
#   
#crontab -e
##   0 2 * * *    sh /root/shell/6-local-repo.sh
#
EXPORT="/mnt/download"
DIR="$EXPORT/centos"
SOURCE="rsync://mirrors.ustc.edu.cn/centos"
#SOURCE="rsync://mirrors.kernel.org/centos"
#SOURCE="rsync://mirrors.neusoft.edu.cn/centos"
#http://mirrors.sohu.com/centos/
#http://mirrors.kernel.org
#http://mirrors.ustc.edu.cn
#http://mirrors.neusoft.edu.cn
[ -f /usr/bin/createrepo ] && yum install -y createrepo
[ -f /etc/yum.repos.d/epel.repo ] && yum install -y  epel-release 
#[ -f /etc/yum.repos.d/rdo-release.repo ] && yum install -y  https://repos.fedorapeople.org/repos/openstack/openstack-ocata/rdo-release-ocata-3.noarch.rpm
mkdir -p $DIR/7/
killall rsync
rsync -avrt --delete $SOURCE/7/extras  $DIR/7
rsync -avrt --delete $SOURCE/7/os      $DIR/7
rsync -avrt --delete $SOURCE/7/updates $DIR/7
rsync -avrt --delete $SOURCE/7/centosplus $DIR/7
rsync -avrt --delete $SOURCE/RPM-GPG-KEY-CentOS-7 $DIR

cd $EXPORT
#reposync --repoid=openstack-ocata
reposync --repoid=epel
#reposync --repoid=rdo-qemu-ev
createrepo epel
#createrepo openstack-ocata
#createrepo rdo-qemu-ev
