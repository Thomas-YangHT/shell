#OS
func_OS(){
  [ "`uname -a|grep Ubuntu`" ] && sys=ubuntu || sys=centos
}

#DATE时间戳
func_TIMESTAMP(){
	TIMESTAMP=`date '+%Y-%m-%d %H:%M:%S'`
}
#net dev name:
func_NETDEV(){
	eth=`ip a|grep $NETWORK|awk '{print $7}'|grep -v "lo:"`
}

#IP
func_IP(){
    IP=`ifconfig $eth |grep "inet "|awk '{print $2}'|sed 's/addr://'`
}

#CPUidle%
func_CPUIDLE(){
    CPUIDLE=`top -bn1 |grep Cpu|awk  '{print $8}'`
}

#内存：total, used 单位KB
func_MEM(){
	memory=(`top -bn1 |grep 'Mem :'|awk '{print $4,$8}'`)
	MEMTOTAL=${memory[0]}
	MEMUSED=${memory[1]}
}

#网络进出带宽, RX, TX, 单位字节B
func_NETSPEED(){
	[ "$sys" = "centos" ] && netpre=(`ifconfig $eth| grep bytes|awk '{print $5}'`) || netpre=(`ifconfig $eth |grep bytes|awk '{print $2,$6}'|sed 's/bytes://g'`)
	sleep 1
	[ "$sys" = "centos" ] && netnext=(`ifconfig $eth| grep bytes|awk '{print $5}'`) || netnext=(`ifconfig $eth |grep bytes|awk '{print $2,$6}'|sed 's/bytes://g'`)
	RX=$((${netnext[0]}-${netpre[0]}))
	TX=$((${netnext[1]}-${netpre[1]}))
}
#根分区的使用率 used
func_DISKROOTRATE(){
    DISKROOTRATE=`df -h|grep "/$"|awk '{print $5}'|sed 's/%//'`
}

#磁盘IO：sda硬盘的等待时间和利用率：await, util%
func_DISKIO(){
	io=(`iostat -x|grep sda|awk '{print $10,$14}'`)
	IOAWAIT=${io[0]}
	IOUTIL=${io[1]}
}
#开放的端口: 协议、IP、Port、PID、procname
func_NETPORTS(){
    NETPORTS=(`netstat -nlptu|awk 'NR>2{if($1~"tcp")print $1"," $4","$7;if($1=="udp")print $1","$4","$6}'|sed -e 's/\//,/g' -e 's/:::/---,/g' -e 's/:/,/g' -e 's/---/:::/g'`)
    echo -n>/tmp/netports.csv
    rows=${#NETPORTS[@]}
    for ((i=1;i<$rows;i++));
    do
       echo "$TIMESTAMP,$IP,${NETPORTS[$i]}" >>/tmp/netports.csv
    done
}

#echo "$TIMESTAMP $IP $CPUIDLE $MEMTOTAL $MEMUSED $RX  $TX $DISKROOTRATE $IOAWAIT $IOUTIL"

#Series Number
func_SN(){
    SN='sudo -i dmidecode -s system-serial-number'
}

#Raid or Harddisk error
func_MegaERR(){
    MegaERR='sudo -i megacli -PDList -aALL |grep Err'
}
