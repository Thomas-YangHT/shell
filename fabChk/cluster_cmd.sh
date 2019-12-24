source ./CONFIG
ips=(`cat ips.txt|awk '{print $1}'|xargs`)

for i in ${ips[*]}
do 
    [ -n "$1" ] && echo -n "$i " && ssh $REMOTE_USER@$i $1
done
