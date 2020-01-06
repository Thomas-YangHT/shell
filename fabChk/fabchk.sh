#!(which bash)
#  _       _                          __  __                 
# | |     (_)  _ __    _   _  __  __ |  \/  |   __ _   _ __  
# | |     | | | '_ \  | | | | \ \/ / | |\/| |  / _` | | '_ \ 
# | |___  | | | | | | | |_| |  >  <  | |  | | | (_| | | | | |
# |_____| |_| |_| |_|  \__,_| /_/\_\ |_|  |_|  \__,_| |_| |_|
#                                                             
#start timestamp
D1=`date +%s`
source ./CONFIG
source ./FUNCTION
[ -n "$2" ] && [ "$2" = "-ip" ] && echo "use ip :$3" && IPS="$3" || IpFile=ips.txt
[ -n "$2" ] && [ "$2" = "-ipfile" ] && [ -f $3 ] && echo "use ip file:$3" && IpFile="$3" || IpFile=ips.txt
[  "$IPS" ] || IPS=`cat $IpFile|grep -vP "^#|^$"|awk '{print $1}'|xargs| sed 's/ /,/g'` 
COUNT=`echo $IPS|wc -w`
#COUNT=`cat $IpFile|grep -vP "^#|^$"|wc -l`)
#
prepareInfo="put collexec shell scripts to hosts in ips.txt"
cpuidleInfo="cpu IDLE"
memInfo="memtotal memused"
rootrateInfo="root usage"
snInfo="Series Number"
diskerrInfo="RAID & Disk error"
funclist=(prepare cpuidle mem rootrate sn diskerr help)
funcinfo=($prepareInfo $cpuidleInfo $memInfo $rootrateInfo $snInfo $diskerrInfo $helpInfo)
#
case $1 in
0|all)
  echo "start all check..."
  func_prepare
  func_cpuidle
  func_mem
  func_rootrate
;;
p|prepare)
  echo "start check " $prepareInfo "..."
  func_prepare
;;
baseinfo)
  echo "start check " $baseInfo "..."
  func_baseinfo
;;
moninfo)
  echo "start check " $monInfo "..."
  func_moninfo
;;
portsinfo)
  echo "start check " $portsInfo "..."
  func_portsinfo
;;
bakinfo)
  echo "start check " $bakInfo "..."
  func_bakinfo
;;
errinfo)
  echo "start check " $errInfo "..."
  func_errinfo
;;
1|cpuidle)
  echo "start check " $cpuidleInfo "..."
  func_cpuidle
;;
2|mem)
  echo "start check "$memInfo"..."
  func_mem
;;
3|rootrate)
  echo "start check "$rootrateInfo"..."
  func_rootrate
;;
4|sn)
  echo "start check "$snInfo"..."
  func_sn
;;
5|diskerr)
  echo "start check "$diskerrInfo"..."
  func_diskerr
;;
help|*)
  echo "usage: $0 [`echo ${funclist[@]}|sed 's/ /|/g'`] [-ip <ip> |-ipfile <filename>]"
  for ((i=1;i<${#funclist[@]};i++))
  do 
    echo ${funclist[i]}"            :"${funcinfo[i]}
  done
;;
esac

#cost seconds
D2=`date +%s`
echo ALL Mission completed in $((D2-D1)) seconds for $COUNT hosts.

#END.
