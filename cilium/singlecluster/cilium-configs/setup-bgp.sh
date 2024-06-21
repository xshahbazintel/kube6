#!/bin/bash

. ../config.sh

# annotate to configure BGP asn for IPv6 only nodes
# Get the list of worker node names
nodes=$(kind get nodes --name $CLUSTER1_NAME)
# Set the router-id values
router_id[0]="127.0.0.1"
router_id[1]="127.0.0.2"
router_id[2]="127.0.0.3"

# Loop through the nodes and annotate them
i=0
for node in $nodes; do
  # Construct the annotation key and value
  key="cilium.io/bgp-virtual-router.64501"
  value="router-id=${router_id[$i]}"
  # Annotate the node
  kubectl --context="${CLUSTER1_CTX}" annotate node $node $key=$value --overwrite
  # Increment the index
  i=$((i+1))
done

# Get the list of worker node names
nodes=$(kind get nodes --name $CLUSTER2_NAME)
# Set the router-id values
router_id[0]="127.0.2.1"
router_id[1]="127.0.2.2"
router_id[2]="127.0.2.3"

# Loop through the nodes and annotate them
i=0
for node in $nodes; do
  # Construct the annotation key and value
  key="cilium.io/bgp-virtual-router.64502"
  value="router-id=${router_id[$i]}"
  # Annotate the node
  kubectl --context="${CLUSTER2_CTX}" annotate node $node $key=$value --overwrite
  # Increment the index
  i=$((i+1))
done

# configure cilium bgp
echo "Configuring bgp in $CLUSTER1_NAME..."
kubectl --context="${CLUSTER1_CTX}" label nodes --all bgp-policy=mck --overwrite
kubectl --context="${CLUSTER1_CTX}" apply -f bgp-clu1.yaml

# configure cilium bgp
echo "Configuring bgp in $CLUSTER2_NAME..."
kubectl --context="${CLUSTER2_CTX}" label nodes --all bgp-policy=mck --overwrite
kubectl --context="${CLUSTER2_CTX}" apply -f bgp-clu2.yaml

# hack static route for native route via bgp peer (FRR_KIND) because cilium bgp don't import peer routes
# without static route native traffic will end up on default gateway with deadend
# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER1_NAME)
# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Adding static route to $node..."
  docker exec $node ip route add 2001:db8:0:0::/32 via fc00:f853:ccd:e793::ffff
done
nodes=$(kind get nodes --name $CLUSTER2_NAME)
# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Adding static route to $node..."
  docker exec $node ip route add 2001:db8:0:0::/32 via fc00:f853:ccd:e793::ffff
done