#!/usr/bin/bash
#
#set_bip_route.sh: 为docker主机自动设定docker0网络和静态路由
#
#定义一个取得配置的函数
func_GET(){
    MYHOST="192.168.31.140"
    DKMAC=`ifconfig docker0|grep ether|awk '{print $2}'`
    IP=`ifconfig eth0| sed -n 's/inet\(.*\)net\(.*\)/\1/p'`
	#取得本机set_bip
    sql="select set_bip \
         from baseinfo2 \
         where dkmac=\"$DKMAC\""   
    BIP=`echo $sql|mysql -uyanght -D monitor -pyanght -h $MYHOST|xargs|awk '{print $2}'`
	#取得其它docker主机的ip和set_bip
	sql2="select ip,set_bip \
         from baseinfo2 \
         where trim(ip)<>trim(\"$IP\") \
	     and set_bip is not NULL"
    IPS=(`echo $sql2|mysql -uyanght -D monitor -pyanght -h $MYHOST`)
}
#执行设定
func_SET_BIP(){    
	FILENAME='/etc/docker/daemon.json'
    #如果已存在$BIP或$BIP为空,则直接退出
	flag=`grep "$BIP"    $FILENAME`
	if [ -n "$flag"  -o -z "$BIP" ];then
	    echo 2
		return 2
	fi
	#如果存在bip行,则替换，否则插入一行
    flag2=`grep -i "bip" $FILENAME`	
    if [ -n "$flag2" ];then
	    sed  -i "s#bip\":.*#bip\":\"$BIP\"#" $FILENAME
	else
	    echo  "{\"bip\":\"$BIP\"}"      >>$FILENAME  
	fi
	#重启docker
	systemctl restart docker
}
#设置到其它docker主机容器的路由
func_SET_ROUTE(){
	length=${#IPS[@]}
	rows=length/2
	for((i=1;i<$rows;i++));
	do
	   DKNET=`echo ${IPS[$i*2+1]}|sed 's#\(.*\)\.\(.*\)/#\1.0/#'`
	   echo "route add -net ${DKNET} gw ${IPS[$i*2]}"|tee /dev/stdout|sh
	done
}
#报告状态
func_REPORT(){
    STATUS=''
    flag=`grep  "$BIP"  $FILENAME`
    if [ -z "$flag" ];then
        STATUS='bip no set'
    fi
    for((i=1;i<$rows;i++));
    do
       flag=`route -n |grep ${IPS[$i*2]}`
       if [ -z "$flag" ];then
          STATUS=`echo $STATUS ${IPS[$i*2]' no route set'`
       fi
    done
    if [ -z "$STATUS" ];then
       STATUS='OK'
    fi
	echo $STATUS
    sql="update baseinfo2 set status=\"$STATUS\"  where dkmac=\"$DKMAC\" "
    echo $sql|mysql -uyanght -D monitor -pyanght -h $MYHOST
}

#---start----
func_GET
func_SET_BIP
func_SET_ROUTE
func_REPORT