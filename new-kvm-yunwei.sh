#new kvm
#set hostname & ip/dns/gw
#
if [ "$1" ];then
  kvmname=$1
  kvmbase="192.168.253.254"
  SUFFIX="$((($RANDOM+1)/254))"
  touch ~/.ssh/config && echo -e "StrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null" >> ~/.ssh/config
  ssh $kvmbase hostnamectl set-hostname $kvmname
  ssh $kvmbase ifconfig eth0 172.16.253.$SUFFIX
  ssh $kvmbase ifconfig eth1 192.168.250.$SUFFIX
  ssh $kvmbase ifconfig eth0
  ssh $kvmbase hostname
  ssh $kvmbase "curl 192.168.254.5/shell/sys_baseinfo-yunwei.sh|bash"
  #ssh $kvmbase "curl 192.168.254.5/shell/docker-registry-yunwei.sh|bash"
else
  echo "Usage: sh new-kvm-yunwei.sh KVMXXX"
fi




