#!/bin/bash

#clean up the whole of bgp config
#this is required if kind clusters ip changes and there are left over configs that bothers you
#deleting bgp configs to current active peers, may take sometime for peers to come up

export LOCAL_AS=65100

docker exec frr_kind vtysh \
    -c "configure terminal" \
    -c " no router bgp $LOCAL_AS" \
    -c "end" \
    -c "write" \
    -c "exit"