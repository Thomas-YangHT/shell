#!/usr/bin/python
from fabric.api import *

def upload():
    put('/root/sys_baseinfo.sh','/root/')
	put('/root/set_ip.sh','/root/')

def exec_baseinfo():
    run('sh sys_baseinfo.sh')

def exec_setip():
    run('sh set_ip.sh')
	
def instcron():
    run('echo "*/5 * * * * /usr/bin/bash /root/set_ip.sh" >>/var/spool/cron/root')

def delecron():
    run('cp  /var/spool/cron/root /var/spool/cron/rootbak')
    run('grep -v "/root/set_ip.sh"  /var/spool/cron/rootbak >/var/spool/cron/root')

def restore_set():
    run('cp -f /etc/sysconfig/network-scripts/ifcfg-eth0.bak  /etc/sysconfig/network-scripts/ifcfg-eth0 ')
    run('systemctl restart network')