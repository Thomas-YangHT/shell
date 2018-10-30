helm template istio --name istio --namespace istio-system --set sidecarInjectorWebhook.enabled=true --set ingress.service.type=NodePort --set gateways.istio-ingressgateway.type=NodePort --set gateways.istio-egressgateway.type=NodePort --set tracing.enabled=true --set servicegraph.enabled=true --set prometheus.enabled=true --set tracing.jaeger.enabled=true --set grafana.enabled=true > istio.yaml


imagenew=(registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/istio:1 \
registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/istio:2 \
registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/istio:3 \
registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/istio:4 \
registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/istio:5 \
registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/ist:1 \
registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/ist:2 \
registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/ist:3 \
registry.cn-zhangjiakou.aliyuncs.com/yanghaitao/ist:4)

for i in ${imagenew[*]}
do 
  docker pull $i
done

images=(gcr.io/istio-release/citadel:1.0.0 \
gcr.io/istio-release/galley:1.0.0 \
gcr.io/istio-release/kubectl:1.0.0 \
gcr.io/istio-release/mixer:1.0.0 \
gcr.io/istio-release/pilot:1.0.0 \
gcr.io/istio-release/proxy_init:1.0.0 \
gcr.io/istio-release/proxyv2:1.0.0 \
gcr.io/istio-release/servicegraph:1.0.0 \
gcr.io/istio-release/sidecar_injector:1.0.0)
j=0
for i in ${images[*]}
do
  name=`echo $i |sed 's#gcr.io/istio-release/\(.*\):#\1#'`
  docker tag  ${imagenew[$j]} $i
  docker save $i >${name}.tar
  (( j++ ))  
done


