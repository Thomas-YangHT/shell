#!/usr/bin/sh
#*/5 * * * * /usr/bin/sh $CONF_DIR/shell/auto_backup.sh
#baksetting: ip,baktype,baknames,bakpolicy
#
#从数据库取得配置
CONF_DIR="/root/shell"
CONF_FILE="$CONF_DIR/baksetting"
MYHOST="192.168.31.140"
sql="select ip,baktype,baknames,bakpolicy from baksetting"    
echo $sql|mysql -uyanght -D moninfo -pyanght -h $MYHOST >$CONF_FILE
echo $sql|sed 's/\\//'|mysql -uyanght -D moninfo -pyanght -h $MYHOST|tr '\t' ','>$CONF_FILE

#取得本机IP所对应的备份配置行数	
if [ -f $CONF_FILE ];then
    ip=`/usr/sbin/ifconfig eth0| /usr/bin/egrep 'inet[^0-9].*' | /usr/bin/awk '{print $2}'`
	rows=`grep "${ip}" $CONF_FILE |wc -l`
    echo "rows:${rows}:"
fi
#判断是否有本机的设置
if (( ${rows} >=1 ));then
    echo "rows:$rows"
else
    echo "No enough setting data."
    exit
fi

#按配置行数，生成备份脚本，按备份策略加入到crontab自动运行    
for ((i=1;i<=$rows;i++));
do 
	baktype=`grep "${ip}" $CONF_FILE|awk -F',' -v n=$i 'NR==n{print $2}'`
	baknames=(`grep "${ip}" $CONF_FILE|awk -F',' -v n=$i 'NR==n{print $3}'`)
	bakpolicy=(`grep "${ip}" $CONF_FILE|awk -F',' -v n=$i 'NR==n{print $4}'`)
	echo ${baktype} 
	echo ${baknames[*]}
	echo ${bakpolicy[*]}
    #ip	baktype	baknames	bakpolicy 
    #baktype: tomcat mysql ...
    case ${baktype} in
        'tomcat')  
            echo "tar zcvf /tmp/apache-tomcat_\`date +%Y%m%d-%H%M%S\`.tgz --exclude=*/logs/* /usr/local/apache-tomcat-* " >$CONF_DIR/tomcatbak.sh
            echo "/usr/bin/rsync -vzrtopg -c -progress  -e ssh /tmp/*tgz  root@192.168.100.21:/mnt/sdc/${ip}/ >>$CONF_DIR/rsync.log"  >>$CONF_DIR/tomcatbak.sh
            echo "find /tmp/apache-tomcat*tgz -mtime +2 -exec rm -f {} \;"  >>$CONF_DIR/tomcatbak.sh
            cmd="/usr/bin/sh $CONF_DIR/tomcatbak.sh"
        ;;
        'mysql')
            dt=`date +%Y%m%d-%H%M%S`
			echo "/usr/bin/mysqldump -uyanght -pyanght -h ${ip} --databases ${baknames[*]} >/tmp/mysql_${dt}.sql" >$CONF_DIR/mysqlbak.sh
			echo "tar zcvf /tmp/mysql_${dt}.tgz /usr/local/mysql_${dt}.sql">>$CONF_DIR/mysqlbak.sh
            echo "/usr/bin/rsync -vzrtopg -c -progress  -e ssh /tmp/mysql_*.tgz  root@192.168.100.11:/mnt/sdc/${ip}/ >>$CONF_DIR/rsync.log"  >>$CONF_DIR/mysqlbak.sh
            echo "find /tmp/mysql_*.sql -mtime +2 -exec rm -f {} \;"  >>$CONF_DIR/mysqlbak.sh
            cmd="/usr/bin/sh $CONF_DIR/mysqlbak.sh"
        ;;
        'docker')
            echo "tar zcvf /tmp/docker_\`date +%Y%m%d-%H%M%S\`.tgz --exclude=*/logs/* /opt/* " >$CONF_DIR/dockerbak.sh
			echo "/usr/bin/rsync -vzrtopg -c -progress  -e ssh /tmp/docker*tgz  root@192.168.100.11:/mnt/sdc/${ip}/ >>$CONF_DIR/rsync.log"  >>$CONF_DIR/dockerbak.sh
			echo "find /tmp/docker*tgz -mtime +2 -exec rm -f {} \;"  >>$CONF_DIR/dockerbak.sh
            cmd="/usr/bin/sh $CONF_DIR/dockerbak.sh"
        ;;
        'mongo')
            echo "" >$CONF_DIR/mongobak.sh
            cmd="/usr/bin/sh $CONF_DIR/mongobak.sh"
        ;;
        'nginx')
            echo "" >$CONF_DIR/nginxbak.sh
            cmd="/usr/bin/sh $CONF_DIR/nginxbak.sh"
        ;;
        'redis')
            echo "" >$CONF_DIR/redis.sh
            cmd="/usr/bin/sh $CONF_DIR/redis.sh"
        ;;    
        'keeepalive')
            echo "" >$CONF_DIR/keeepalive.sh
            cmd="/usr/bin/sh $CONF_DIR/keeepalive.sh"
        ;;        
        'zookeeper')
            echo "" >$CONF_DIR/zookeeper.sh
            cmd="/usr/bin/sh $CONF_DIR/zookeeper.sh"
        ;;    
        'mycat')
            echo "" >$CONF_DIR/mycat.sh
            cmd="/usr/bin/sh $CONF_DIR/mycat.sh"
        ;;        
        'dubbo')
            echo "" >$CONF_DIR/dubbo.sh
            cmd="/usr/bin/sh $CONF_DIR/dubbo.sh"
        ;;
        'SpringBoot')
            echo "" >$CONF_DIR/SpringBoot.sh
            cmd="/usr/bin/sh $CONF_DIR/SpringBoot.sh"
        ;;            
        *)
            cmd=""
            echo "${config[$i*4+1]}..."
        ;;
    esac
    
    #bakpolicy: 分 时 日 月 天  
	p2=$(echo ${bakpolicy[*]}|sed 's/\\\*/\*/g')
	p=`echo ${bakpolicy[*]}|sed  -e 's/\\\//g'`
    echo "p:${p}:${p2}"
    #if p not empty
    if [[ -n "${p}" && -n "${cmd}" ]];then
        st=$(grep "${p2} $cmd" /var/spool/cron/root)
        st2=`grep "$cmd" /var/spool/cron/root`
        echo "st:$st:$st2:"
        #if st empty
        if [[ ! -n "$st" ]];then
            #if st2 empty
            if [[ ! -n "$st2" ]];then
                echo "Install $cmd into cron"
                  echo "${p} $cmd"  >>/var/spool/cron/root
            else
                echo "Already have $cmd, replace it..."
                grep -v "$cmd" /var/spool/cron/root >/tmp/root.tmp
                cat /tmp/root.tmp >/var/spool/cron/root
                echo "${p} $cmd"  >>/var/spool/cron/root
            fi
        else
            echo "Already have same $p $cmd in /var/spool/cron/root"
        fi
    fi
        
done