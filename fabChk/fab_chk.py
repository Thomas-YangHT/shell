from fabric.api import *

def test():
    run('echo hello world')

def prepare():
	put('collconf','')
	put('collexec.sh','')
	put('collfunc','')

def baseinfo():
    run('bash ./collexec.sh baseinfo')

def moninfo():
    run('bash ./collexec.sh moninfo')

def portsinfo():
    run('bash ./collexec.sh portsinfo')

def bakinfo():
    run('bash ./collexec.sh bakinfo')

def errinfo():
    run('bash ./collexec.sh errinfo')

def os():
    run('bash ./collexec.sh os')

def sn():
    run('bash ./collexec.sh sn')

def cpuidle():
    run('bash ./collexec.sh cpuidle')

def timestamp():
    run('bash ./collexec.sh timestamp')

def ip():
    run('bash ./collexec.sh ip')

def mem():
    run('bash ./collexec.sh mem')

def netspeed():
    run('bash ./collexec.sh netspeed')

def diskrootrate():
    run('bash ./collexec.sh diskrootrate')

def diskio():
    run('bash ./collexec.sh diskio')

def diskerr():
    run('bash ./collexec.sh diskerr')
