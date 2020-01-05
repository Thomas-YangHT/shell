from fabric.api import *

def test():
    run('echo hello world')

def prepare():
	put('collconf','')
	put('collexec.sh','')
	put('collfunc','')

def mem():
    run('bash ./collexec.sh mem')

def cpuidle():
    run('bash ./collexec.sh cpuidle')

def rootrate():
    run('bash ./collexec.sh rootrate')

def sn():
    run('bash ./collexec.sh sn')

def diskerr():
    run('bash ./collexec.sh diskerr')
