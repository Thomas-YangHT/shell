https://docs.gitlab.com/runner/install/kubernetes.html
https://blog.csdn.net/kansuke_zola/article/details/80483421
http://gitlab.yunwei.edu/help/user/project/clusters/index.md#installing-applications


#https://blog.csdn.net/weiguang1017/article/details/78045013
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.6.1-linux-amd64.tar.gz
#解包并将二进制文件helm拷贝到/usr/local/bin目录下
tar -zxvf helm-v2.6.1-linux-amd64.tgz && mv linux-amd64/helm /usr/local/bin/helm
helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.11.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

helm install --name my-mariadb --set Persistence.StorageClass=slow stable/mariadb 
（不加--set参数会出现SchedulerPredicates failed due to PersistentVolumeClaim is not bound: "", which is unexpected问题）

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/nginx-ingress-controller:0.20.0
