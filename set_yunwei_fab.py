#!/usr/bin/python
from fabric.api import *

#env.roledefs={ 'hosts':['192.168.254.1','192.168.254.7'],'kvm':['192.168.1.22','192.168.1.24']}
def env-hosts():
    env.hosts=['192.168.254.1','192.168.254.2','192.168.254.3','192.168.254.4','192.168.254.5','192.168.254.6','192.168.254.7']

def env-kvms():
    env.hosts=['kvm110','kvm111','kvm112','kvm113','kvm120','kvm121','kvm122','kvm123']

def env-port-host():
    env.port='30022'

def env-port-kvm():
    env.port='22'

def uptime():
    run('uptime')

def upload():
    put('/root/shell/sys_baseinfo-yunwei.sh','/root/')
    put('/root/shell/set_ip-yunwei.sh','/root/')
    put('/root/shell/2-bond5-yunwei.sh','/root/')
    put('/root/shell/virt-clone-yunwei.sh','/root/')
    put('/root/shell/*hosts','/root/')
    put('/root/shell/*hosts','/root/')

def exec_baseinfo():
    run('sh sys_baseinfo-yunwei.sh')

def exec_set_ip_kvm():
    run('sh set_ip-yunwei.sh')

def exec_set_ip_host():
    run('sh 2-bond5-yunwei.sh')
	
def instcron-set-ip-kvm():
    run('echo "*/5 * * * * /usr/bin/bash /root/set_ip-yunwei.sh" >>/var/spool/cron/root')

def delecron-set-ip-kvm():
    run('cp  /var/spool/cron/root /var/spool/cron/rootbak')
    run('grep -v "/root/set_ip-yunwei.sh"  /var/spool/cron/rootbak >/var/spool/cron/root')


