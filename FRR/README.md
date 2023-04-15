## Update the below values in the setup-bgp.sh

add BGP peers in the PEERS array, The values in the array can be IPv4 or IPv6 address e.g.

export PEERS=(fd74:ca9b:3a09:868c:10:9:65:1 fd74:ca9b:3a09:868c:10:9:65:2)

Define local AS e.g.

export LOCAL_AS=65100

Define remote AS that is configured on the metallb side e.g.

export REMOTE_AS=64500

### run ./setup.sh will setup frr and also bgp peering

### If you want to run the script for multiple clusters with different remote AS on the metallb side, please run the script individually for each cluster.