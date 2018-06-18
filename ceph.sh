

#Config:
node1="192.168.31.13"
node2="192.168.31.14"
node3="192.168.31.15"
SUBNET="192.168.31.0"
IMAGE="ceph/daemon"
REGISTRY="192.168.31.140:5000"
NODES=($node1 $node2 $node3)
#node1 --mon
NODE=$node1

DK_cmd_mon="
docker run \
-d --net=host  \
--name=mon \
-v /etc/ceph:/etc/ceph \
-v /var/lib/ceph/:/var/lib/ceph \
-e MON_IP=$NODE \
-e CEPH_PUBLIC_NETWORK=$SUBNET/24 \
$REGISTRY/$IMAGE \
Mon"

ssh $node1 $DK_cmd_mon

#modify ceph.conf
#....
   scp -r $node1:/etc/ceph $node2:/etc/ceph
   scp -r $node1:/etc/ceph $node3:/etc/ceph
   scp -r $node1:/var/lib/ceph $node2:/var/lib/ceph
   scp -r $node1:/var/lib/ceph $node3:/var/lib/ceph
   
for NODE in $node2 $node3
do
   echo $NODE
   DK_cmd_mon="
docker run \
-d --net=host  \
--name=mon \
-v /etc/ceph:/etc/ceph \
-v /var/lib/ceph/:/var/lib/ceph \
-e MON_IP=$NODE \
-e CEPH_PUBLIC_NETWORK=$SUBNET/24 \
$REGISTRY/$IMAGE \
Mon"
   echo $DK_cmd_mon
   ssh $NODE $DK_cmd_mon
done

#check mon:
for NODE in ${NODES[@]}
do 
 echo $NODE":"
 ssh $NODE docker exec mon ceph -s
done

#start osd in every node:
DK_cmd_OSD="
docker run \
-d --net=host \
--name=osd \
--privileged=true \
--pid=host \
-v /etc/ceph:/etc/ceph \
-v /var/lib/ceph/:/var/lib/ceph/ \
-v /dev/:/dev/ \
-e OSD_DEVICE=/dev/vdb \
-e OSD_TYPE=disk   \
$REGISTRY/$IMAGE \
Osd"

for NODE in ${NODES[@]}
do 
 echo $NODE":"
 ssh $NODE $DK_cmd_OSD
done

#check osd:
for NODE in ${NODES[@]}
do 
 echo $NODE":"
 ssh $NODE docker exec osd ceph -s
done
#注：有没启动成功的OSD，重新格式化磁盘再启动

#RGW
DK_cmd_RGW="
docker run \
-d --net=host \
--name=rgw \
-v /etc/ceph:/etc/ceph \
-v /var/lib/ceph/:/var/lib/ceph  \
$REGISTRY/$IMAGE \
rgw"
NODE=$node3
ssh $NODE $DK_cmd_RGW
ssh $NODE docker exec rgw ceph -s

#MDS:
DK_cmd_MDS="
docker run \
-d --net=host \
--name=mds \
-v /etc/ceph:/etc/ceph \
-v /var/lib/ceph/:/var/lib/ceph \
-e CEPHFS_CREATE=1 \
$REGISTRY/$IMAGE \
mds"
NODE=$node2
ssh $NODE $DK_cmd_MDS
ssh $NODE docker exec mds ceph -s

#MGR:
DK_cmd_MGR="
docker run \
-d --net=host  \
--name=mgr \
-v /etc/ceph:/etc/ceph \
-v /var/lib/ceph/:/var/lib/ceph \
$REGISTRY/$IMAGE \
mgr"
for NODE in ${NODES[@]}
do 
 echo $NODE":"
 ssh $NODE $DK_cmd_MGR
done

#check mgr:
for NODE in ${NODES[@]}
do 
 echo $NODE":"
 ssh $NODE docker exec mgr ceph -s
done

#没有开启dashboard未解决
docker exec mon ceph mgr dump
docker exec mgr ceph mgr module enable dashboard

#挂载CEPH FS:可以使用集群的任意结点IP挂载
ssh $node1 cat /etc/ceph/ceph.client.admin.keyring
mkdir /mnt/mycephfs
mount -t ceph $node2:6789:/ /mnt/mycephfs -o name=admin,secret=<key>
umount /mnt/mycephfs
mount -t ceph $node1:6789:/ /mnt/mycephfs -o name=admin,secretfile=/etc/ceph/admin.secret
umount /mnt/mycephfs
#secretfile报错未解决

#s3client test rgw:
wget "https://gist.githubusercontent.com/kairen/e0dec164fa6664f40784f303076233a5/raw/33add5a18cb7d6f18531d8d481562d017557747c/s3client"
chmod u+x s3client
pip install boto
docker exec -ti rgw radosgw-admin user create --uid="test" --display-name="I'm Test account" --email="test@example.com"

cat >s3key.sh <<EOF
export S3_ACCESS_KEY="BRBWKZ3URKOTHB7792S0",
export S3_SECRET_KEY="tpC7X0vGJa8kQFWsbceD2MLspWStYZ6Y27WhB2Py"
export S3_HOST="127.0.0.1"
export S3_PORT="8080"
EOF
source ./s3key.sh
./s3client list
./s3client create files
./s3client upload files s3key.sh /
./s3client list files