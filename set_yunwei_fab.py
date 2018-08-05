#!/usr/bin/python
from fabric.api import *

#env.roledefs={ 'hosts':['192.168.254.1','192.168.254.7'],'kvm':['192.168.1.22','192.168.1.24']}
def env_hosts():
    env.hosts=['192.168.254.1','192.168.254.2','192.168.254.3','192.168.254.4','192.168.254.5','192.168.254.6','192.168.254.7']

def env_kvms():
    env.hosts=['kvm110','kvm111','kvm112','kvm113','kvm120','kvm121','kvm122','kvm123']

def env_port_host():
    env.port='30022'

def env_port_kvm():
    env.port='22'

def uptime():
    run('uptime')

def upload():
    put('/root/shell/sys_baseinfo-yunwei.sh','/root/')
    put('/root/shell/set_ip-yunwei.sh','/root/')
    put('/root/shell/2-bond5-yunwei.sh','/root/')
    put('/root/shell/virt-clone-yunwei.sh','/root/')

def upload_hosts():
    put('/root/shell/all_hosts','/etc/hosts')

def upload_iptables():
    put('/root/shell/iptables','/etc/sysconfig/iptables')
    put('/root/shell/iptables.init','/usr/libexec/iptables/iptables.init')
    put('/root/shell/iptables.services','/usr/lib/systemd/system/iptables.service')

def upload_yum_yunwei():
    run('cd /etc/yum.repos.d;wget 192.168.254.251/shell/*yunwei.repo')    

def exec_baseinfo():
    run('sh sys_baseinfo-yunwei.sh')

def exec_set_ip_kvm():
    run('sh set_ip-yunwei.sh')

def exec_set_ip_host():
    run('sh 2-bond5-yunwei.sh')
	
def instcron_set_ip_kvm():
    run('echo "*/5 * * * * /usr/bin/bash /root/set_ip-yunwei.sh" >>/var/spool/cron/root')

def delecron_set_ip_kvm():
    run('cp  /var/spool/cron/root /var/spool/cron/rootbak')
    run('grep -v "/root/set_ip-yunwei.sh"  /var/spool/cron/rootbak >/var/spool/cron/root')

def zbx_agent_stop():
    #run('cd /opt/cmp_zabbix;sh zbx_agent-st2.sh')
    run('cd /opt/cmp_zabbix;docker-compose stop;docker-compose rm;')

def zbx_agent_start():
    run('cd /opt/cmp_zabbix;docker-compose up -d;docker-compose restart')

def zbx_agent_status():
    run('ss -nltp|grep 10050 && echo running || echo stoped ')

