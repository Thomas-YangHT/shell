tar zcvf /tmp/docker_`date +%Y%m%d-%H%M%S`.tgz --exclude=*/logs/* /opt/* 
/usr/bin/rsync -vzrtopg -c -progress  -e ssh /tmp/docker*tgz  root@192.168.100.11:/mnt/sdc/192.168.100.222/ >>/root/shell/rsync.log
find /tmp/docker*tgz -mtime +2 -exec rm -f {} \;
