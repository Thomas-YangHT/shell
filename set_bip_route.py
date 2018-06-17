#!/usr/bin/python
from fabric.api import *

def upload():
    put('/root/sys_baseinfo2.sh','/root/')
    put('/root/set_bip_route.sh','/root/')

def exec_baseinfo2():
    run('sh /root/sys_baseinfo2.sh')

def exec_setbip():
    run('sh /root/set_bip_route.sh')
	
def instcron():
    run('echo "*/5 * * * * /usr/bin/bash /root/set_bip_route.sh" >>/var/spool/cron/root')

def delecron():
    run('cp -f /var/spool/cron/root /var/spool/cron/rootbak')
    run('grep -v "/root/set_bip_route.sh"  /var/spool/cron/rootbak >/var/spool/cron/root')

def help():
    help='''
1. upload    ---------sys_baseinfo2.sh&set_bip_route.sh;
2. exec_baseinfo2-----sys_baseinfo2.sh;
3. exec_setbip--------set_bip_route.sh;
4. instcron  ---------install set_bip_route.sh from cron;
5. delecron  ---------delete set_bip_route.sh from cron;
'''
    print help
