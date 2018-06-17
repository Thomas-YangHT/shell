#!/usr/bin/bash
#
#set_ip.sh:  Get new IP setting from CMDB and do it.
#
#从数据库取得设置参数
func_GET(){
    FILENAME="/etc/sysconfig/network-scripts/ifcfg-eth0"
	MYHOST="192.168.31.222"
    #UUID=`nmcli c|grep eth0|awk '{print $2}'`
	UUID=`grep -Po "UUID=\K.*" $FILENAME`
    MAC=`ifconfig eth0|grep ether|awk '{print $2}'`
  
    sql="select set_hostname, set_ip, set_prefix, set_gwip, set_dns1 \
         from baseinfo \
         where mac=\"$MAC\""
    
    RESULTS=(`echo $sql|mysql -uyanght -D monitor -pyanght -h $MYHOST`)
    i=5
    #i表示设定项目数量，检查结果数据是否为5项(去除表头)
    if [ $((${#RESULTS[@]}/2)) = $i ];then
      echo 1
      SET_hostname=${RESULTS[$i]}
      SET_ip=${RESULTS[$i+1]}
      SET_prefix=${RESULTS[$i+2]}
      SET_gwip=${RESULTS[$i+3]}
      SET_dns1=${RESULTS[$i+4]}
    else 
      echo 2
      return 2
    fi
}
#设置主机名
func_SET_HOSTNAME(){
    #设置主机名,不同则修改
    if [ "$SET_hostname" != `hostname` ];then
       echo $SET_hostname >/etc/hostname
       hostname $SET_hostname
    fi
}

#设定eth0的配置文件
func_FILE(){
cat >$FILENAME <<EOF
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=eth0
DEVICE=eth0
ONBOOT=yes
UUID=$UUID
HWADDR=$MAC
DNS1=$SET_dns1
DNS2=192.168.100.2
IPADDR=$SET_ip
PREFIX=$SET_prefix
GATEWAY=$SET_gwip
PROXY_METHOD=none
BROWSER_ONLY=no
EOF
}
#重启相关服务
func_RESTART(){
    systemctl stop NetworkManager
    systemctl restart network	
    #systemctl start NetworkManager
	#systemctl restart docker
}

#报告设置结果
func_REPORT(){
	HOSTNAME=`hostname`
	IP=$(echo `ifconfig eth0| sed -n 's/inet\(.*\)net\(.*\)/\1/p'`)
	#GWIP=$(echo `netstat -rn|grep eth0|sed -n 's/0.0.0.0\(.*\) 0.0.0.0.*/\1/p'`)
	GWIP=`grep -Po "GATEWAY=\K.*" $FILENAME`
	PREFIX=`grep -Po "PREFIX=\K.*" $FILENAME`
    #DETECT_dns1=`grep $SET_dns1 /etc/resolv.conf |wc -l`
	DETECT_dns1=`grep $SET_dns1 $FILENAME|wc -l`
	echo $HOSTNAME,$IP,$GWIP,$PREFIX,$DETECT_dns1
	STATUS=''
    if [ "$HOSTNAME" != "$SET_hostname" ];then 
	    STATUS='hostname not set'
	fi
	if [ "$GWIP" != "$SET_gwip" ];then
	    STATUS=$STATUS' GWIP no set'
	fi
	if [ "$IP" != "$SET_ip" ];then
	   STATUS=$STATUS' IP no set'
	fi
	if [  "$PREFIX" != "$SET_prefix" ];then
	   STATUS=$STATUS' PREFIX no set'
	fi
	if [  "$DETECT_dns1" = 0 ];then
	   STATUS=$STATUS' DNS1 no set'
	fi
	if [ -z "$STATUS" ];then
	   STATUS='OK'
	fi
    sql="update baseinfo set status=\"$STATUS\"  where mac=\"$MAC\"  "
    echo $sql|mysql -uyanght -D monitor -pyanght -h $MYHOST

}
#定义一个修改配置文件的函数,这里写了一个ifcfg-eth0的模板
func_SET_IP(){
    #检查新设定是否有变化,避免重复修改
    j=`cat $FILENAME|grep -P "$SET_ip|$SET_gwip|$SET_dns1|$SET_prefix"|wc -l`
    if [ $(($i-1)) = $j ];then 
        echo 3
    else 
        echo 4
        #备份eth0配置
        cp $FILENAME $FILENAME.bak
        func_FILE
        func_RESTART
    	func_REPORT
    fi
}
#---start----
func_GET
func_SET_HOSTNAME
func_SET_IP
