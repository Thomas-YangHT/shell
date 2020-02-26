from fabric.api import *

def test():
    run('echo hello world')

ExecDir='~/monagent.client/'

def prepare():
    run('rm -f collconf collexec.sh collfunc;[ -d '+ExecDir+' ] ||  mkdir '+ExecDir+' && echo "already exist '+ExecDir+'"')
    put('collconf',ExecDir)
    put('collexec.sh',ExecDir)
    put('collfunc',ExecDir)

def baseinfo():
    run('cd '+ExecDir+';bash ./collexec.sh baseinfo')

def moninfo():
    run('cd '+ExecDir+';bash ./collexec.sh moninfo')

def portsinfo():
    run('cd '+ExecDir+';bash ./collexec.sh portsinfo')

def bakinfo():
    run('cd '+ExecDir+';bash ./collexec.sh bakinfo')

def errinfo():
    run('cd '+ExecDir+';bash ./collexec.sh errinfo')

def os():
    run('cd '+ExecDir+';bash ./collexec.sh os')

def sn():
    run('cd '+ExecDir+';bash ./collexec.sh sn')

def cpuidle():
    run('cd '+ExecDir+';bash ./collexec.sh cpuidle')

def timestamp():
    run('cd '+ExecDir+';bash ./collexec.sh timestamp')

def ip():
    run('cd '+ExecDir+';bash ./collexec.sh ip')

def mem():
    run('cd '+ExecDir+';bash ./collexec.sh mem')

def netspeed():
    run('cd '+ExecDir+';bash ./collexec.sh netspeed')

def diskrootrate():
    run('cd '+ExecDir+';bash ./collexec.sh diskrootrate')

def diskio():
    run('cd '+ExecDir+';bash ./collexec.sh diskio')

def diskerr():
    run('cd '+ExecDir+';bash ./collexec.sh diskerr')
