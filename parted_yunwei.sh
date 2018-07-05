#ip a add 172.16.254.5/16 dev em1
#ip route add default via 172.16.0.1 dev em1
#
yum groupinstall "GNOME Desktop"
#parted
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart xfs 0G 3000G
parted /dev/sdb mkpart xfs 3000G 3489G
mkfs.xfs /dev/sdb1
mkfs.xfs /dev/sdb2
echo "/dev/sdb1    /mnt   xfs   default  0 0" >>/etc/fstab
echo "/dev/sdb2    /opt   xfs   default  0 0" >>/etc/fstab