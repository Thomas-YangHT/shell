IMAGES="centos-source-neutron-lbaas-agent \
centos-source-neutron-vpnaas-agent \
centos-source-panko-api \
centos-source-gnocchi-metricd \
centos-source-gnocchi-api \
centos-source-gnocchi-statsd \
centos-source-ceilometer-notification \
centos-source-ceilometer-compute \
centos-source-ceilometer-central \
centos-source-ceilometer-api \
centos-source-ceilometer-collector \
centos-source-rally \
centos-source-trove-api \
centos-source-trove-conductor \
centos-source-trove-taskmanager \
centos-source-cloudkitty-api \
centos-source-cloudkitty-processor"
IMAGES="centos-source-cloudkitty-api \
centos-source-cloudkitty-processor"
IMAGE_NAME=""
REGISTRY="192.168.31.140:5000"
for IMAGE_NAME in $IMAGES
do
#[ "$1" ] && IMAGE_NAME=$1 || exit 1  
docker pull kolla/$IMAGE_NAME:ocata
docker tag kolla/$IMAGE_NAME:ocata $REGISTRY/99cloud/$IMAGE_NAME:4.0.2.1
docker push $REGISTRY/99cloud/$IMAGE_NAME:4.0.2.1
done
