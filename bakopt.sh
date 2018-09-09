
DDATE=`date +%Y%m%d-%H%M%S`
KEEPDAY=14
BAKDIR='/export/backup'
[ -d /export/backup ] && cd /export/backup || mkdir /export/backup 
[ -d /export/backup/mnt ] || mkdir /export/backup/mnt
#backup yunwei opt110
mount -t nfs4 192.168.254.251:/ /export/backup/mnt
sleep 3
tar zcvf /export/backup/opt110_$DDATE.tgz --exclude=*/nginxlog/* --exclude=*/download/* --exclude=*/mysql/* --exclude=*/mysql_binlog/*
  /export/backup/mnt/*
umount /export/backup/mnt
#backup yunwei opt 5
tar zcvf /export/backup/opt5_$DDATE.tgz.tgz --exclude=*/nginxlog/* --exclude=*/download/* --exclude=*/mysql/* --exclude=*/mysql_binlog
/*  /opt/*

#backup mysql
/usr/bin/mysqldump -uyanght -pyanght -h 192.168.254.251 --databases monitor moninfo docker cmdb zabbix >./mysql_$DDATE.sql
tar zcvf /export/backup/mysql_$DDATE.tgz ./mysql_$DDATE.sql
rm -f /export/backup/*sql
find /export/backup/*tgz -mtime +${KEEPDAY} -exec rm -f {} \;


