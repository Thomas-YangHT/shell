ip link add veth01 type veth peer name veth10
brctl addif br0 veth01
brctl addif br1 veth10
ip link set veth01 up
ip link set veth10 up
brctl show
