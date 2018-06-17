#!/usr/bin/bash
#
MYHOST='192.168.31.140'
HOSTNAME=`hostname`
TZ=`tail -n 1 /etc/localtime`
KERNEL=`uname -ro`
MAC=`ifconfig eth0|grep ether|awk '{print $2}'`
IP=`ifconfig eth0| sed -n 's/inet\(.*\)net\(.*\)/\1/p'`
CPU=`cat /proc/cpuinfo |grep 'model name'|awk -F':' '{print $2}'|uniq -c`
MEMORY=`cat /proc/meminfo |grep MemTotal`
DISK=`fdisk -l |grep -v mapper|grep -Po 'Disk /dev/\K.*GB'|xargs`
SERIESNO=`dmidecode -s system-serial-number`
DKMAC=`ifconfig docker0|grep ether|awk '{print $2}'`
DKIP=`ifconfig docker0| sed -n 's/inet\(.*\)net\(.*\)/\1/p'`

echo $HOSTNAME, $KERNEL, $TZ, $MAC, $IP, $CPU, $MEMORY, $DISK, $SERIESNO, $DKMAC, $DKIP
if [ -z "$DKIP" ];then
    echo "No docker ip can be found."
	exit
fi
sql="select mac from baseinfo2 where mac=\"$MAC\""
flag=`echo $sql|mysql -uyanght -D monitor -pyanght -h $MYHOST`
if [ -z "$flag" ];then
  sql="insert into baseinfo2(hostname, kernel, tz, mac, ip, cpu, memory, disk, seriesno, dkmac, dkip) \
   select \"$HOSTNAME\",\"$KERNEL\",\"$TZ\", \"$MAC\", \"$IP\", \"$CPU\",  \"$MEMORY\", \"$DISK\", \"$SERIESNO\",\"$DKMAC\",\"$DKIP\" "
  echo $sql|mysql -uyanght -D monitor -pyanght -h $MYHOST
fi