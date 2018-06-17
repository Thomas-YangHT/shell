/usr/bin/mysqldump -uyanght -pyanght -h 192.168.100.222 --databases monitor moninfo docker cmdb >/tmp/mysql_20180416-215004.sql
tar zcvf /tmp/mysql_20180416-215004.tgz /tmp/mysql_20180416-215004.sql
/usr/bin/rsync -vzrtopg -c -progress  -e ssh /tmp/mysql_*.tgz  root@192.168.100.11:/mnt/sdc/192.168.100.222/ >>/root/shell/rsync.log
find /tmp/mysql_*.sql -mtime +2 -exec rm -f {} \;
