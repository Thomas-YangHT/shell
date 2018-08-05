tee cmd.txt<<EOF
nmcli
ifconfig
free
cat 
cpuinfo
egrep 
locale
localtime
EOF
for i in `cat cmd.txt`; do echo "wget man.linuxde.net/$i;mv $i $i.html"; done|sh
sed -i 's/man.linuxde.net/man.yunwei.edu/g' *html