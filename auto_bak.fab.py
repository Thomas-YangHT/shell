#!/usr/bin/python
from fabric.api import *

def upload():
    put('/root/auto_backup.sh','/root/')

def exec_autobak():
    run('sh auto_backup.sh')

def instcron():
    run('echo "*/5 * * * * /usr/bin/bash /root/auto_backup.sh" >>/var/spool/cron/root')

def delecron():
    run('cp  /var/spool/cron/root /var/spool/cron/rootbak')
    run('grep -v "/root/auto_backup.sh"  /var/spool/cron/rootbak >/var/spool/cron/root')
