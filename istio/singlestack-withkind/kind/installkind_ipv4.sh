#!/bin/bash
. ../config.sh

# Exit script if kind not installed
if ! command -v kind &> /dev/null
then
  echo "Kind not found, please install out of script..."
  exit 1
fi

# Create an ipv6 single stack cluster
echo "Creating cluster $CLUSTER_NAME..."
kind create cluster --name $CLUSTER_NAME --config cluster_ipv4.yaml

# Verify that the cluster is running
echo "Verifying cluster $CLUSTER_NAME..."
kubectl cluster-info --context kind-$CLUSTER_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER_NAME)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
done

