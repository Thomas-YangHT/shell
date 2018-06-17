#!/usr/bin/bash
#
#check docker container's bridge network IP
#
docker network inspect bridge|sed -n '/Containers/,/"Options"/p'|grep -v Option|grep -v Containers|grep -P "{|IPv4Address"|sed -e 's/"\(.*\)":.*{/\1/' -e 's/.*": "\(.*\)",/\1/'|awk '{printf $0" ";if(NR%2==0)print ""}'|awk '{print substr($1,0,12),$2}'>2
docker ps -a >1
awk 'NR==FNR{a[$1]=$0}NR>FNR{print $0,a[$1]}' 1 2
