ETH=`ifconfig |grep -P "^br0|^br1|^eth0|^em1"|awk -F':' '{print $1}'|head -n1`

export LC_ALL=en_US.UTF-8
HOSTNAME=`hostname`
TZ=`tail -n 1 /etc/localtime`
KERNEL=`uname -ro`
MAC=`ifconfig $ETH|grep ether|awk '{print $2}'`
IP=`ifconfig $ETH| sed -n 's/inet\(.*\)net\(.*\)/\1/p'`
CPU=`cat /proc/cpuinfo |grep 'model name'|awk -F':' '{print $2}'|uniq -c`
MEMORY=`cat /proc/meminfo |grep MemTotal`
DISK=`sudo fdisk -l |grep -v mapper|grep -Po 'Disk /dev/\K.*GB'|xargs`
SERIESNO=`sudo dmidecode -s system-serial-number`

echo $HOSTNAME, $KERNEL, $TZ, $MAC, $IP, $CPU, $MEMORY, $DISK, $SERIESNO

sql="insert into baseinfo(hostname, kernel, tz, mac, ip, cpu, memory, disk, seriesno) \
     select \"$HOSTNAME\",\"$KERNEL\",\"$TZ\", \"$MAC\", \"$IP\", \"$CPU\",  \"$MEMORY\", \"$DISK\", \"$SERIESNO\" "
echo $sql