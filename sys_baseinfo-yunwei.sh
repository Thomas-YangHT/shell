#!/usr/bin/bash
#
#sys_baseinfo.sh:   Get sys_base_info and report to CMDB
#
MYHOST="192.168.251.211"
(ping 192.168.251.211 -c 1 && MYHOST=192.168.251.211) || (ping 192.168.254.211 -c 1 && MYHOST=192.168.254.211)

export LC_ALL=en_US.UTF-8
HOSTNAME=`hostname`
TZ=`tail -n 1 /etc/localtime`
KERNEL=`uname -ro`
MAC=`ifconfig eth0|grep ether|awk '{print $2}'`
IP=`ifconfig eth0| sed -n 's/inet\(.*\)net\(.*\)/\1/p'`
CPU=`cat /proc/cpuinfo |grep 'model name'|awk -F':' '{print $2}'|uniq -c`
MEMORY=`cat /proc/meminfo |grep MemTotal`
DISK=`fdisk -l |grep -v mapper|grep -Po 'Disk /dev/\K.*GB'|xargs`
SERIESNO=`dmidecode -s system-serial-number`

echo $HOSTNAME, $KERNEL, $TZ, $MAC, $IP, $CPU, $MEMORY, $DISK, $SERIESNO

sql="insert into baseinfo(hostname, kernel, tz, mac, ip, cpu, memory, disk, seriesno) \
     select \"$HOSTNAME\",\"$KERNEL\",\"$TZ\", \"$MAC\", \"$IP\", \"$CPU\",  \"$MEMORY\", \"$DISK\", \"$SERIESNO\" "
echo $sql|mysql -uyanght -D monitor -pyanght -h $MYHOST
