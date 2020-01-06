#!(which bash)
source ./collfunc
source ./collconf

#define information for help
osInfo="os type"
timestampInfo="timestamp"
netdevInfo="network device"
ipInfo="ip"
cpuidleInfo="cpu idle%"
memInfo="memory TOTAL USED"
netspeedInfo="net speed RX TX"
diskrootrateInfo="root Usage %"
diskioInfo="disk IO await util%"
netportsInfo="opened Ports"
snInfo="series number"
megaerrInfo="error of raid or disk"
funclist=(os timestamp netdev ip cpuidle mem netspeed diskrootrate diskio netports sn megaerr)
funcinfo=($osInfo $timestampInfo $netdevInfo $ipInfo $cpuidleInfo $memInfo $netspeedInfo $diskrootrateInfo $diskioInfo $netportsInfo $snInfo $megaerrInfo)
#把获取的信息分成五组：
#		baseinfo		基本信息
#		moninfo			监控信息
#		portsinfo       端口信息
#		bakinfo			备份信息
#		errinfo			错误信息：如硬盘故障
case $1 in
baseinfo)
  func_baseinfo
;;
moninfo)
  func_OS 
  func_TIMESTAMP
  func_NETDEV
  func_IP
  func_CPUIDLE
  func_MEM
  func_NETSPEED
  func_DISKROOTRATE
  func_DISKIO
  echo "$TIMESTAMP $IP $CPUIDLE $MEMTOTAL $MEMUSED $RX  $TX $DISKROOTRATE $IOAWAIT $IOUTIL"
;;
portsinfo)
  func_NETPORTS
  cat /tmp/netports.csv  
;;
bakinfo)
  func_bakinfo
;;
errorinfo)
  func_MegaERR
  echo "$MegaERR"
;;
1|os)
  func_OS &&   echo $sys
;;
2|sn)
  func_SN &&   echo $SN
;;
diskerr)
  func_MegaERR
  echo $MegaERR
;;
help|*)
  echo "usage: $0 [`echo ${funclist[@]}|sed 's/ /|/g'`] [-ip <ip> |-ipfile <filename>]"
  for ((i=1;i<${#funclist[@]};i++))
  do 
    echo ${funclist[i]}"            :"${funcinfo[i]}
  done
;;
esac
