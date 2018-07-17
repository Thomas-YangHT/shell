sh new-kvm-yunwei.sh kvmi"$1"
echo "pls set ip in mysql, and then press ENTER to continue..."
read
ssh 192.168.253.254 "curl 192.168.253.5/shell/set_ip-yunwei.sh|sh"
