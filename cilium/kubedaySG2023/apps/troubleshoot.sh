#!/bin/bash

. ../../config.sh

# makesure the clustermesh is properly setup and all the routes are available on the nodes
cilium clustermesh status --context $CLUSTER1_CTX --wait

echo "check $CLUSTER1_NAME worker routes "
docker exec -it clu5-worker ip route