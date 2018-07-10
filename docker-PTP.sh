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
centos-source-cloudkitty-processor \
centos-source-iscsid "
IMAGES="centos-source-tgtd"
for IMAGE in $IMAGES
do
  docker pull kolla/$IMAGE:ocata
  docker tag  kolla/$IMAGE:ocata 192.168.31.140:5000/99cloud/$IMAGE:4.0.2.1
  docker push 192.168.31.140:5000/99cloud/$IMAGE:4.0.2.1
done 