#new kvm
if [ "$1" ];then
  kvmname=$1
  kvmbase="192.168.254.254"
  touch ~/.ssh/config && echo -e "StrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null" >> ~/.ssh/config
  ssh $kvmbase hostnamectl set-hostname $kvmname
  ssh $kvmbase ifconfig eth0 172.16.253.$(($RANDOM+1/254))
  ssh $kvmbase ifconfig eth0
  #ssh $kvmbase "curl 192.168.254.5/shell/docker-registry-yunwei.sh|bash"
else
  echo "Usage: sh new-kvm-yunwei.sh KVMXXX"
fi




