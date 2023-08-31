#!/bin/bash

. ../../config.sh

# Create cluster5 cluster
echo "Creating cluster $CLUSTER5_NAME..."
kind create cluster --name $CLUSTER5_NAME --config cluster5.yaml


# Create cluster6 cluster
echo "Creating cluster $CLUSTER6_NAME..."
kind create cluster --name $CLUSTER6_NAME --config cluster6.yaml


# Verify that the cluster is running
echo "Verifying cluster $CLUSTER5_NAME..."
kubectl cluster-info --context kind-$CLUSTER5_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER5_NAME)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
done

# Verify that the cluster is running
echo "Verifying cluster $CLUSTER6_NAME..."
kubectl cluster-info --context kind-$CLUSTER6_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER6_NAME)

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
kind load docker-image --name $CLUSTER5_NAME quay.io/cilium/cilium:v1.14.1
kind load docker-image --name $CLUSTER6_NAME quay.io/cilium/cilium:v1.14.1

# add helm repo to both clusters
echo "Adding cilium helm repo..."
helm repo add cilium https://helm.cilium.io/

# install cilium
echo "Installing cilium in $CLUSTER5_NAME..."
helm install cilium cilium/cilium --version 1.14.1 --kube-context $CLUSTER5_CTX \
   --namespace kube-system \
   --set cluster.name=clu5 \
   --set cluster.id=5 \
   --set operator.replicas=1 \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes \
   --set bgpControlPlane.enabled=true

echo "Installing cilium in $CLUSTER6_NAME..."
helm install cilium cilium/cilium --version 1.14.1 --kube-context $CLUSTER6_CTX \
   --namespace kube-system \
   --set cluster.name=clu6 \
   --set cluster.id=6 \
   --set operator.replicas=1 \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes \
   --set bgpControlPlane.enabled=true

# prepare clustermesh
echo "Installing cilium-ca secret..."
kubectl --context $CLUSTER6_CTX delete secret cilium-ca -n kube-system
kubectl --context=$CLUSTER5_CTX get secret -n kube-system cilium-ca -o yaml | \
   kubectl --context $CLUSTER6_CTX create -f -

# enable clustermesh
echo "Enabling cilium clustermesh..."
cilium clustermesh enable --context $CLUSTER5_CTX --service-type LoadBalancer
cilium clustermesh enable --context $CLUSTER6_CTX --service-type LoadBalancer

cilium clustermesh status --context $CLUSTER5_CTX --wait
cilium clustermesh status --context $CLUSTER6_CTX --wait

# connect clusters
echo "Connecting cilium $CLUSTER5_NAME and $CLUSTER6_NAME..."
cilium clustermesh connect --context $CLUSTER5_CTX --destination-context $CLUSTER6_CTX
cilium clustermesh status --context $CLUSTER5_CTX --wait