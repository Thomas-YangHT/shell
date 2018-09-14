#!/usr/bin/bash
#检查主机是否能ping通
#1---正常
#0---不正常
#命令示例
#a=`ping 192.168.254.10 -c 1|grep -Po "transmitted, \K.* r" |sed 's/ r//' `
#[ $a -eq 0 ] && echo 0 || echo 1

#hosts=(`cat /etc/hosts|awk '{print $1}'`)

sql="select ip from moninfo.hostip where status<>'close'"
hosts=(`echo $sql |mysql -uyanght -pyanght -h 172.16.254.110|tail -n +2`)
status=""

for host in ${hosts[@]}
do
    a=`ping $host -c 1|grep -Po "transmitted, \K.* r" |sed 's/ r//' `
    [ $a -eq 0 ] && echo "$host,0" || echo "$host,1"
	[ $a -eq 0 ] && status+="err01 " ||  status+="running "
done

#结果更新数据库
i=0
for stat in $status
do
    ((i++))
    sql="update moninfo.hostip set status='$stat' where ip='${hosts[$i]}'"
	echo $sql |mysql -uyanght -pyanght -h 172.16.254.110
done
