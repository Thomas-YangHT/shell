#!/usr/bin/bash
#
#  _       _                          __  __                 
# | |     (_)  _ __    _   _  __  __ |  \/  |   __ _   _ __  
# | |     | | | '_ \  | | | | \ \/ / | |\/| |  / _` | | '_ \ 
# | |___  | | | | | | | |_| |  >  <  | |  | | | (_| | | | | |
# |_____| |_| |_| |_|  \__,_| /_/\_\ |_|  |_|  \__,_| |_| |_|
#                                                             
#
#start timestamp
D1=`date +%s`
source ./CONFIG
source ./FUNCTION
[ -n "$2" ] && ([ "$2" = "-ip" ] || [ "$2" = "--ip-file" ]) && [ -f $3 ] && echo "use ip file:$3" && IpFile="$3" \
|| IpFile=ips.txt
echo IPFile：$IpFile

IPS=`cat $IpFile|grep -vP "^#|^$"|awk '{print $1}'|xargs| sed 's/ /,/g'`
COUNT=`cat $IpFile|grep -vP "^#|^$"|wc -l`

#
case $1 in
0|all)
  echo "start all check..."
  func_cpu
  func_mem
  func_disk
;;
1|cpu)
  echo "start check cpu IDLE..."
  func_cpu
;;
2|mem)
  echo "start check mem TOTAL USED FREE SHARED  buff/cache   available..."
  func_mem
;;
3|disk)
  echo "start check disk USAGE..."
  func_disk
;;
4|sn)
  echo "start check SN..."
  func_sn
;;
5|raid)
  echo "start check RAID & Disk error..."
  func_raid
;;
help|*)
  echo "usage: $0 [cpu|mem|disk|sn|help|...   [-c|--config  /path/to/config.filename]"
  echo -e "\
        cpu            :cpu.\n\
        mem            :memory.\n\
        disk           :disk..\n\
        sn             :series number...\n\
  "
;;
esac

#cost seconds
D2=`date +%s`
echo ALL Mission completed in $((D2-D1)) seconds for $COUNT hosts.

#END.
