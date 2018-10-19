kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/rbac.yaml
curl https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/calico.yaml -O

sed -i 's@.*etcd_endpoints:.*@\ \ etcd_endpoints:\ \"https://10.100.24.20:2379,https://10.100.24.21:2379,https://10.100.24.22:2379\"@gi' calico.yaml

export ETCD_CERT=`cat /etc/etcd/ssl/etcd.pem | base64 | tr -d '\n'` 
export ETCD_KEY=`cat /etc/etcd/ssl/etcd-key.pem | base64 | tr -d '\n'` 
export ETCD_CA=`cat /etc/etcd/ssl/ca.pem | base64 | tr -d '\n'`

sed -i "s@.*etcd-cert:.*@\ \ etcd-cert:\ ${ETCD_CERT}@gi" calico.yaml 
sed -i "s@.*etcd-key:.*@\ \ etcd-key:\ ${ETCD_KEY}@gi" calico.yaml 
sed -i "s@.*etcd-ca:.*@\ \ etcd-ca:\ ${ETCD_CA}@gi" calico.yaml 

sed -i 's@.*etcd_ca:.*@\ \ etcd_ca:\ "/calico-secrets/etcd-ca"@gi' calico.yaml 
sed -i 's@.*etcd_cert:.*@\ \ etcd_cert:\ "/calico-secrets/etcd-cert"@gi' calico.yaml 
sed -i 's@.*etcd_key:.*@\ \ etcd_key:\ "/calico-secrets/etcd-key"@gi' calico.yaml 

kubectl apply -f calico.yaml

https://docs.projectcalico.org/v3.2/getting-started/kubernetes/
kubectl apply -f \
https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/etcd.yaml
kubectl apply -f \
https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/rbac.yaml
wget \
https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/calico.yaml
sed -i 's#192.168.0.0#10.244.0.0#g' calico.yaml
问题: 下不到镜相，只好用阿里云转一下，master上4个全要下，node上只要node/cni
docker pull registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/myhub:3.2.3-1
docker pull registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/myhub:3.2.3-2
docker pull registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/myhub:3.2.3-3
docker pull registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/myhub:3.2.3-4
docker tag registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/myhub:3.2.3-1 quay.io/calico/kube-controllers:v3.2.3
docker tag registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/myhub:3.2.3-2 quay.io/calico/cni:v3.2.3
docker tag registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/myhub:3.2.3-3 quay.io/calico/node:v3.2.3
docker tag registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/myhub:3.2.3-4 quay.io/coreos/etcd:v3.3.9
问题2：连接不到bgp
重启服务器后正常


