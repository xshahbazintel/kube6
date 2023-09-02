#!/bin/bash

. ../../config.sh

# Create cluster3 cluster
echo "Creating cluster $CLUSTER3_NAME..."
kind create cluster --name $CLUSTER3_NAME --config cluster3.yaml


# Create cluster4 cluster
echo "Creating cluster $CLUSTER4_NAME..."
kind create cluster --name $CLUSTER4_NAME --config cluster4.yaml


# Verify that the cluster is running
echo "Verifying cluster $CLUSTER3_NAME..."
kubectl cluster-info --context kind-$CLUSTER3_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER3_NAME)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
done

# Verify that the cluster is running
echo "Verifying cluster $CLUSTER4_NAME..."
kubectl cluster-info --context kind-$CLUSTER4_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER4_NAME)

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
kind load docker-image --name $CLUSTER3_NAME quay.io/cilium/cilium:v1.14.1
kind load docker-image --name $CLUSTER4_NAME quay.io/cilium/cilium:v1.14.1

# add helm repo to both clusters
echo "Adding cilium helm repo..."
helm repo add cilium https://helm.cilium.io/

# install cilium
echo "Installing cilium on $CLUSTER3_NAME..."
helm install cilium cilium/cilium --version 1.14.1 --kube-context $CLUSTER3_CTX \
   --namespace kube-system \
   --set cluster.name=clu3 \
   --set cluster.id=3 \
   --set operator.replicas=1 \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes \
   --set bgpControlPlane.enabled=true \
   --set tunnel=disabled \
   --set ipv4NativeRoutingCIDR=10.0.0.0/8

echo "Installing cilium on $CLUSTER4_NAME..."
helm install cilium cilium/cilium --version 1.14.1 --kube-context $CLUSTER4_CTX \
   --namespace kube-system \
   --set cluster.name=clu4 \
   --set cluster.id=4 \
   --set operator.replicas=1 \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes \
   --set bgpControlPlane.enabled=true \
   --set tunnel=disabled \
   --set ipv4NativeRoutingCIDR=10.0.0.0/8