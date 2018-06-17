#!/usr/bin/sh
#checking backup filename,count,space occupation
#
/usr/bin/find  /mnt/sdc -name "*tgz" -type f  -exec ls -lh {} \; |sort -r -k 9| /usr/bin/awk '{split($0,a,"/");if(a[5] ~/apache-tomcat/){aaa=substr(a[5],1,20)};print a[4],aaa}'|uniq -c|sort -k2>/tmp/1.txt
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

>/root/bakinfo
for ((i=0;i<$rows;i++));
do
	space=`du -csh /mnt/sdc/${file[$i*3+1]}/${file[$i*3+2]}*|grep total|awk '{print $1}'`
	echo "`date +'%Y%m%d %H%M%S'`,${file[$i*3+1]},${file[$i*3+2]}*.tgz,${file[$i*3]},$space">>/root/bakinfo
	
done
echo "------------------------" >>/tmp/1.txt
/usr/bin/df -h |grep mnt >>/tmp/1.txt
/usr/bin/du -sh /mnt/sdc/* >>/tmp/1.txt
echo "------------------------" >>/tmp/1.txt
/usr/bin/find  /mnt/sdc -name "*tgz" -type f  -exec ls -lh {} \; |sort -r -k 9 >>/tmp/1.txt
ln -s /tmp/1.txt /usr/share/nginx/html/bakdetail.txt
#http://192.168.100.21/bakdetail.txt
