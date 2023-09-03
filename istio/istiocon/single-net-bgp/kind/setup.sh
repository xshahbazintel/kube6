#!/bin/bash

# Invoke the kind script
#source installkind.sh
## Wait for 5 sec
#sleep 5
#
#
#
## Invoke the metallb script
#source installmetallb.sh

The sequence should be adjusted to. cuz of dependencies on bgp and no tunneling, the cluster won't come up correctly without below sequence
setupkind
setupbgp-frr
setupbgp-cilium
wait 30sec
setup metallb