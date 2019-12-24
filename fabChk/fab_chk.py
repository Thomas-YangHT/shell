from fabric.api import *

def test():
    run('echo hello world')

def mem():
    run('free -m |grep Mem|awk -v DATE="${a}" \'{print DATE" "$0}\'')

def cpu():
    #run('top -bn1 |grep Cpu|awk  \'{print $8}\'')
    run('top -bn1|grep Cpu|grep -Po ".*ni,\K.*id"|sed -e \'s/id//\' -e \'s/%//\'')

def disk():
    run('df -h|grep G')

def sn():
    run('sudo -i dmidecode -s system-serial-number')

def raid():
    run('sudo -i megacli -PDList -aALL |grep Err')
