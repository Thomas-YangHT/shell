tar zcvf /tmp/apache-tomcat_`date +%Y%m%d-%H%M%S`.tgz --exclude=*/logs/* /usr/local/apache-tomcat-* 
/usr/bin/rsync -vzrtopg -c -progress  -e ssh /tmp/*tgz  root@192.168.100.21:/mnt/sdc// >>/root/rsync.log
find /tmp/apache-tomcat*tgz -mtime +2 -exec rm -f {} \;
