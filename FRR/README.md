## Update the below values in the setup-bgp.sh

ipv6_addrs > all the worker nodes addresses that will be included in bgp peering

local_as > local AS of the FRR docker container

remote_as > the AS configured on the metallb side

### run ./setup.sh will setup frr and also bgp peering
