#配置参考https://blog.csdn.net/admin_root1/article/details/78911718
#为KVM虚拟机附加ISO并起动：
#virsh attach-disk kvm01 /mnt/software/CentOS-7-x86_64-Minimal-1511.iso hdc --driver file --type cdrom --mode readonly --current

docker load < /root/cobbler.tar
mount /dev/cdrom /repo
docker run -d --net=host --name cobbler -v /repo:/repo cobbler
sleep 60
docker cp /root/.ssh/id_rsa.pub cobbler:/var/www/cobbler/pub/
#docker exec cobbler cobbler import --name=CentOS-7 --path=/repo/ --kickstart=/var/lib/cobbler/kickstarts/centos-7.ks
#docker exec cobbler cobbler profile edit --name CentOS-7-x86_64 --kopts 'ipaddr=10.99.0.3:255.255.255.0:10.99.0.1:control02'
#docker exec cobbler cobbler profile add --name CentOS-7.a-x86_64 --distro CentOS-7-x86_64 --kickstart /var/lib/cobbler/kickstarts/centos-7.a.ks --enable-menu=false

#进入cobbler docker修改cobbler密码：
docker exec -it cobbler bash
htdigest /etc/cobbler/users.digest "Cobbler" cobbler
#http://192.168.31.11:81/cobbler_web 登陆：cobbler/cobbler 导入ISO
cp /etc/cobbler/settings{,.ori}
sed -i 's/server: 127.0.0.1/server: 192.168.31.11/' /etc/cobbler/settings
sed -i 's/next_server: 127.0.0.1/next_server: 192.168.31.11/' /etc/cobbler/settings
#管理dhcp
sed -i 's/manage_dhcp: 0/manage_dhcp: 1/' /etc/cobbler/settings
#防止重装
sed -i 's/pxe_just_once: 0/pxe_just_once: 1/' /etc/cobbler/settings
#修改dhcp模板
sed -i.ori 's#192.168.1#192.168.31#g;22d;23d' /etc/cobbler/dhcp.template

#重启cobbler
docker restart cobbler

