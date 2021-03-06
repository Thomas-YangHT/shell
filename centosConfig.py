import yaml   
import commands

path='/var/lib/coreos-install/user_data'
pathrun='/var/lib/centos-config/user_data'
cmd='HWADDR=`ip a show dev eth0|grep -Po "ether \K\w+:\w+:\w+:\w+:\w+:\w+"`;sed -i "s/HWADDR=.*/HWADDR=$HWADDR/g" '+path
(status,datavalue) = commands.getstatusoutput(cmd)
print "cmd:"+str(status)+":"+str(datavalue)
(status,diffvalue) = commands.getstatusoutput('diff '+path+' '+pathrun)
if status != 0 :
    (status,datevalue) = commands.getstatusoutput('cp -f '+path+' '+pathrun)
    f=open(path)  
    CONFDIC=yaml.load(f) 
    user=CONFDIC['users'][0]['name']
    sshkey=CONFDIC['users'][0]['ssh-authorized-keys'][0]
    hostname=CONFDIC['hostname']
    ifname=CONFDIC['centos']['units'][0]['name']
    ifcfg=CONFDIC['centos']['units'][0]['content']
    ifcfgpath='/etc/sysconfig/network-scripts/'
    sshkeypath='/root/.ssh/'
    print diffvalue
    (status,datevalue) = commands.getstatusoutput('echo """'+ifcfg+'""">'+ifcfgpath+ifname)
    (status,datevalue) = commands.getstatusoutput('echo """'+sshkey+'""">'+sshkeypath+'authorized_keys')
    (status,datevalue) = commands.getstatusoutput('hostnamectl set-hostname '+hostname)
    (status,datevalue) = commands.getstatusoutput('logger Update config'+str(diffvalue[0]))
    (status,datevalue) = commands.getstatusoutput('reboot')
else :
    print 'Config is uptodate'    

