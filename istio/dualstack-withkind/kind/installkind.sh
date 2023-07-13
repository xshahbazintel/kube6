#!/bin/bash

# Install kind if not already installed
if ! command -v kind &> /dev/null
then
  echo "Installing kind..."
  go install sigs.k8s.io/kind@v0.19.0 # use go install instead of go get
fi

CLUSTER_NAME=ipv6singlestack

# Create an ipv6 single stack cluster
echo "Creating cluster $CLUSTER_NAME..."
kind create cluster --name $CLUSTER_NAME --config cluster_ipv6.yaml

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

