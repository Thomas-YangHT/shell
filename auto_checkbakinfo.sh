#!/usr/bin/sh
#checking backup filename,count,space occupation
#
func_SEARCH(){
    #if(a[5] ~/apache-tomcat/){aaa=substr(a[5],1,20)};: 目的是把文件名截取到月份，即第20个字母，要根据具体备份文件名判断；
    #if(a[5] ~/docker/){aaa=substr(a[5],1,13)};
    #if(a[5] ~/mysql/){aaa=substr(a[5],1,12)};
    /usr/bin/find  /mnt/sdc -name "*tgz" -type f  -exec ls -lh {} \; |sort -r -k 9| \
        /usr/bin/awk '{split($0,a,"/");if(a[5] ~/apache-tomcat/){aaa=substr(a[5],1,20)};\
    	if(a[5] ~/docker/){aaa=substr(a[5],1,13)}; \
    	if(a[5] ~/mysql/){aaa=substr(a[5],1,12)};  \
    	print a[4],aaa}'|uniq -c|sort -k2>/tmp/1.txt
    file=(`/usr/bin/cat /tmp/1.txt`)
    length=${#file[@]}
    rows=$[$length / 3]
    echo "length:$length:"
    if (( ${rows} >=1 ));then
    	echo "rows:$rows"
    else
    	echo "No enough setting data."
    	exit
    fi
}

func_BAKINFO(){
    >/root/bakinfo.csv
    for ((i=0;i<$rows;i++));
    do
    	#${file[$i*3+1]}是IP，${file[$i*3+2]}是到月份的文件名，这句是按月份统计这个文件备份的总空间
    	space=`du -csh /mnt/sdc/${file[$i*3+1]}/${file[$i*3+2]}*|grep total|awk '{print $1}'`
    	#日期、IP、文件名到月份、备份数，占用空间＝》》输出到bakinfo报表csv格式文件；
    	echo "`date +'%Y%m%d %H%M%S'`,${file[$i*3+1]},${file[$i*3+2]}*.tgz,${file[$i*3]},$space">>/root/bakinfo.csv	
    done
}

func_SAVETODB(){
    MYHOST="192.168.31.140"
    sql="LOAD DATA LOCAL INFILE '/root/bakinfo.csv'  INTO TABLE bakinfo CHARACTER SET utf8  FIELDS TERMINATED BY ',' (date, ip, filename,count,space);"
    echo $sql|mysql -uyanght -D moninfo -pyanght -h $MYHOST
}

func_DETAIL(){
    echo "------------------------" >>/tmp/1.txt
    /usr/bin/df -h |grep mnt >>/tmp/1.txt
    /usr/bin/du -sh /mnt/sdc/* >>/tmp/1.txt
    echo "------------------------" >>/tmp/1.txt
    /usr/bin/find  /mnt/sdc -name "*tgz" -type f  -exec ls -lh {} \; |sort -r -k 9 >>/tmp/1.txt
    scp /tmp/1.txt 192.168.100.222:/opt/adm/bakdetail.txt
    #ln -s /tmp/1.txt /usr/share/nginx/html/bakdetail.txt
    #http://192.168.100.21/bakdetail.txt
}
func_SEARCH
func_BAKINFO
func_SAVETODB
func_DETAIL
