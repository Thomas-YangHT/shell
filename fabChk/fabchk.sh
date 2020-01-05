#!$(which bash)
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
[  "$IPS" ] || (IPS=`cat $IpFile|grep -vP "^#|^$"|awk '{print $1}'|xargs| sed 's/ /,/g'` && \
COUNT=`cat $IpFile|grep -vP "^#|^$"|wc -l`)
#
cpuidleInfo="cpu IDLE"
memInfo="memtotal memused"
rootrateInfo="root usage"
snInfo="Series Number"
diskerrInfo="RAID & Disk error"
funclist=(cpuidle mem rootrate sn diskerr help)
funcinfo=($cpuidleInfo $memInfo $rootrateInfo $snInfo $diskerrInfo $helpInfo)
#
case $1 in
0|all)
  echo "start all check..."
  func_cpuidle
  func_mem
  func_rootrate
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
