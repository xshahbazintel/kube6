#!/bin/bash

. ../../config.sh

# configure cilium bgp
echo "Configuring bgp in $CLUSTER1_NAME..."
kubectl --context="${CLUSTER3_CTX}" label nodes --all bgp-policy=istio
kubectl --context="${CLUSTER3_CTX}" apply -f bgp-clu3.yaml

# configure cilium bgp
echo "Configuring bgp in $CLUSTER4_NAME..."
kubectl --context="${CLUSTER4_CTX}" label nodes --all bgp-policy=istio
kubectl --context="${CLUSTER4_CTX}" apply -f bgp-clu4.yaml

# hack static route for native route via bgp peer (FRR_KIND) because cilium bgp don't import peer routes
# without static route native traffic will end up on default gateway with deadend
# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER3_NAME)
# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Adding static route to $node..."
  docker exec $node ip route add 10.0.0.0/8 via 172.18.255.251
done
nodes=$(kind get nodes --name $CLUSTER4_NAME)
# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Adding static route to $node..."
  docker exec $node ip route add 10.0.0.0/8 via 172.18.255.251
done