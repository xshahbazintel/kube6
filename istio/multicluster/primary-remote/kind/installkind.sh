#!/bin/bash

. ../../config.sh

# Create CLUSTER7 cluster
echo "Creating cluster $CLUSTER7_NAME..."
kind create cluster --name $CLUSTER7_NAME --config cluster.yaml


# Create CLUSTER8 cluster
echo "Creating cluster $CLUSTER8_NAME..."
kind create cluster --name $CLUSTER8_NAME --config cluster.yaml


# Verify that the cluster is running
echo "Verifying cluster $CLUSTER7_NAME..."
kubectl cluster-info --context kind-$CLUSTER7_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER7_NAME)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
done

# Verify that the cluster is running
echo "Verifying cluster $CLUSTER8_NAME..."
kubectl cluster-info --context kind-$CLUSTER8_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER8_NAME)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
done

# Load CNI images to both clusters
echo "Pulling cilium image to a docker host..."
docker pull quay.io/cilium/cilium:v1.14.1

echo "load cilium image to the clusters..."
kind load docker-image --name $CLUSTER7_NAME quay.io/cilium/cilium:v1.14.1
kind load docker-image --name $CLUSTER7_NAME quay.io/cilium/cilium:v1.14.1

# add helm repo to both clusters
echo "Adding cilium helm repo..."
helm repo add cilium https://helm.cilium.io/

# install cilium
echo "Installing cilium on $CLUSTER7_NAME..."
helm install cilium cilium/cilium --version 1.14.1 --kube-context $CLUSTER7_CTX \
   --namespace kube-system \
   --set operator.replicas=1 \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

echo "Installing cilium on $CLUSTER8_NAME..."
helm install cilium cilium/cilium --version 1.14.1 --kube-context $CLUSTER8_CTX \
   --namespace kube-system \
   --set operator.replicas=1 \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes