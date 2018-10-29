#Question: error for fluent-es: no plugin concat
#Answer:
docker run -it --name fluent k8s.gcr.io/fluentd-elasticsearch:v2.2.0 bash
  gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
  gem install fluent-plugin-concat
docker commit fluent k8s.gcr.io/fluentd-elasticsearch:v2.2.1
docker save k8s.gcr.io/fluentd-elasticsearch:v2.2.1 >fluent-es-v2.2.1.tar
scp fluent-es-v2.2.1.tar core@coreb1:.
---
ssh core@coreb1
docker load <./fluent-es-v2.2.1.tar
kubectl set image  daemonset fluentd-es-v2.2.1  fluentd-es=k8s.gcr.io/fluentd-elasticsearch:v2.2.1 -n kube-system

#May be cause low performance of cluster

#Question: kibana's.yaml SERVER_BASEPATH
#A: marked # two lines

#Question: fluentd-es's yaml nodeSelector
#A: marked # two lines

 L=`cat efk/kibana-deployment.yaml |grep -n SERVER_BASEPATH|awk -F':' '{print $1+1}'`
 sed  -i "$L s/.*/#\0/" efk/kibana-deployment.yaml 
 
 L=`cat efk/fluentd-es-ds.yaml |grep -n nodeSelector|awk -F':' '{print $1+1}'` && \
 sed  -i "$L s/.*/#\0/" efk/fluentd-es-ds.yaml
 