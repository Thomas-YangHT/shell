#!$(which bash)
##收集服务器基础性能数据

#Config network before run
NETWORK=192.168.10
MYSQL=192.168.10.28

#OS
[ "`uname -a|grep Ubuntu`" ] && sys=ubuntu || sys=centos

#DATE时间戳
TIMESTAMP=`date '+%Y-%m-%d %H:%M:%S'`

eth=`ip a|grep $NETWORK|awk '{print $7}'|grep -v "lo:"`

#IP
IP=`ifconfig $eth |grep "inet "|awk '{print $2}'|sed 's/addr://'`

#CPUidle%
CPUIDLE=`top -bn1 |grep Cpu|awk  '{print $8}'`

#内存：total, used 单位KB
memory=(`top -bn1 |grep 'Mem :'|awk '{print $4,$8}'`)
MEMTOTAL=${memory[0]}
MEMUSED=${memory[1]}

#网络进出带宽, RX, TX, 单位字节B
[ "$sys" = "centos" ] && netpre=(`ifconfig $eth| grep bytes|awk '{print $5}'`) \
|| netpre=(`ifconfig $eth |grep bytes|awk '{print $2,$6}'|sed 's/bytes://g'`)
sleep 1
[ "$sys" = "centos" ] && netnext=(`ifconfig $eth| grep bytes|awk '{print $5}'`) \
|| netnext=(`ifconfig $eth |grep bytes|awk '{print $2,$6}'|sed 's/bytes://g'`)
RX=$((${netnext[0]}-${netpre[0]}))
TX=$((${netnext[1]}-${netpre[1]}))

#根分区的使用率 used
DISKROOTRATE=`df -h|grep "/$"|awk '{print $5}'|sed 's/%//'`

#磁盘IO：sda硬盘的等待时间和利用率：await, util%
io=(`iostat -x|grep sda|awk '{print $10,$14}'`)
IOAWAIT=${io[0]}
IOUTIL=${io[1]}

#开放的端口: 协议、IP、Port、PID、procname
NETPORTS=(`netstat -nlptu|awk 'NR>2{if($1~"tcp")print $1"," $4","$7;if($1=="udp")print $1","$4","$6}'|sed -e 's/\//,/g' -e 's/:::/---,/g' -e 's/:/,/g' -e 's/---/:::/g'`)

echo "$TIMESTAMP $IP $CPUIDLE $MEMTOTAL $MEMUSED $RX  $TX $DISKROOTRATE $IOAWAIT $IOUTIL"

echo -n>/tmp/netports.csv
rows=${#NETPORTS[@]}
for ((i=1;i<$rows;i++));
do
     echo "$TIMESTAMP,$IP,${NETPORTS[$i]}" >>/tmp/netports.csv
done

##建数据库和表后，将数据插入数据库
sql1="LOAD DATA LOCAL INFILE '/tmp/netports.csv'  INTO TABLE ports CHARACTER SET utf8  FIELDS TERMINATED BY ',' (timestamp, ip,protocol, ipl, port, pid, procname);"
sql2="insert into basemon(timestamp, ip, cpuidle,memtotal,memused,rx,tx,diskrootrate,ioawait,ioutil) values(\"$TIMESTAMP\",\"$IP\",$CPUIDLE, $MEMTOTAL, $MEMUSED, $RX,  $TX, $DISKROOTRATE, $IOAWAIT, $IOUTIL)"
sql3="delete from ports where ip='$IP'"
echo $sql1 $sql2 $sql3
echo $sql3|mysql -uyanght -D monitor -pyanght -h $MYSQL
echo $sql1|mysql -uyanght -D monitor -pyanght -h $MYSQL
echo $sql2|mysql -uyanght -D monitor -pyanght -h $MYSQL

