#
#安装coreos in KVM
###准备http下载， 相关文件。。。
mkdir /mnt/smhttp;cd /mnt/smhttp;  python -m SimpleHTTPServer 8000
wget https://stable.release.core-os.net/amd64-usr/current/coreos_production_iso_image.iso
BASEURL="https://stable.release.core-os.net/amd64-usr/current/"
FILES="version.txt\
 coreos_production_image.bin.bz2 \
 coreos_production_image.bin.bz2.DIGESTS \
 coreos_production_image.bin.bz2.DIGESTS.asc \
 coreos_production_image.bin.bz2.DIGESTS.sig \
 coreos_production_image.bin.bz2.sig "
for FILE in $FILES
do
  wget $BASEURL$FILE
done 
source version.txt
mkdir $COREOS_VERSION
mv coreos_production* $COREOS_VERSION


#新建虚拟机
virt-install -n coreos -r 1500 \
--disk /mnt/kvmtest/centos-7.qcow2.coreos1,format=qcow2,size=5 \
--network bridge=br0 \
--os-type=linux --os-variant=rhel7 \
--cdrom /mnt/kvmtest/coreos_production_iso_image.iso \
--vnc --vncport=5911 --vnclisten=0.0.0.0

#iso启动后,console上执行：
sudo mkfs.xfs /dev/vda
sudo wget http://192.168.31.202/static.network
sudo wget http://192.168.31.202/cloud-config.yaml
sudo coreos-install -d /dev/vda -c cloud-config.yaml -b http://192.168.31.202