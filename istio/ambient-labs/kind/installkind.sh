#!/bin/bash

# Exit script if kind not installed
if ! command -v kind &> /dev/null
then
  echo "Kind not found, please install out of script..."
  exit 1
fi

# Create a cluster with name ambient
echo "Creating cluster ambient..."
kind create cluster --name ambient --config cluster.yaml

# Verify that the cluster is running
echo "Verifying cluster ambient..."
kind get clusters
kubectl cluster-info --context kind-ambient

# Get the list of kind nodes
nodes=$(kind get nodes --name ambient)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
  docker exec $node apt install -y ipset
done

