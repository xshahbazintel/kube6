#!/bin/bash

. ../../config.sh

# Create CLUSTER1 cluster
echo "Creating cluster $CLUSTER1_NAME..."
kind create cluster --name $CLUSTER1_NAME --config cluster1.yaml

# Verify that the cluster is running
echo "Verifying cluster $CLUSTER1_NAME..."
kubectl cluster-info --context kind-$CLUSTER1_NAME

# Get the list of kind nodes
nodes=$(kind get nodes --name $CLUSTER1_NAME)

# Loop through each node and update the inotify parameters
for node in $nodes; do
  echo "Updating inotify parameters on $node..."
  docker exec $node sysctl -w fs.inotify.max_user_instances=1024
  docker exec $node sysctl -w fs.inotify.max_user_watches=1048576
  docker exec $node apt update
  docker exec $node apt install -y tcpdump
done


# Load CNI images to both clusters
echo "Pulling calico images to a docker host..."
docker pull docker.io/calico/cni:v3.26.4
docker pull docker.io/calico/node:v3.26.4
docker pull docker.io/calico/kube-controllers:v3.26.4

echo "load calico images to the clusters..."
kind load docker-image --name $CLUSTER1_NAME docker.io/calico/cni:v3.26.4
kind load docker-image --name $CLUSTER1_NAME docker.io/calico/node:v3.26.4
kind load docker-image --name $CLUSTER1_NAME  docker.io/calico/kube-controllers:v3.26.4

# add helm repo to both clusters
#echo "Adding cilium helm repo..."
#helm repo add cilium https://helm.cilium.io/
#
## install cilium
#echo "Installing cilium in $CLUSTER1_NAME..."
#helm install cilium cilium/cilium --version 1.14.1 --kube-context $CLUSTER1_CTX \
#   --namespace kube-system \
#   --set cluster.name=clu1 \
#   --set cluster.id=1 \
#   --set operator.replicas=1 \
#   --set image.pullPolicy=IfNotPresent \
#   --set ipam.mode=kubernetes \
#   --set bgpControlPlane.enabled=true \
#   --set tunnel=disabled \
#   --set ipv4.enabled=false \
#   --set ipv6.enabled=true \
#   --set enableIPv6Masquerade=true \
#   --set autoDirectNodeRoutes=true \
#   --set ipv6NativeRoutingCIDR="2001:db8:0:0::/32" \
#   --set hubble.enabled=true \
#   --set hubble.relay.enabled=true \
#   --set hubble.ui.enabled=true \
#   --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}"