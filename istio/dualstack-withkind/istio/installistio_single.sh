#!/bin/bash

. ../config.sh

# Download images to a docker host
echo "Pulling images to a docker host..."
docker pull $HUB/pilot:$TAG
docker pull $HUB/proxyv2:$TAG

# Load Images to a kind cluster
echo "Loading images to a $CLUSTER_CTX..."
kind load docker-image --name $CLUSTERV6_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTERV6_NAME $HUB/proxyv2:$TAG
echo "Istio images loaded."

# point this to your latest build binary
#istioctl_latest=~/dev/istio/out/linux_amd64/istioctl

# Install istio ambient profile
echo "Installing istio..."
istioctl install -f iop_single.yaml --skip-confirmation

# Verify that istio is installed
echo "Verifying istio installation..."
istioctl verify-install
# Verify that istio is installed
echo "Verifying istio pods and ds..."
kubectl get pods -n istio-system
kubectl get daemonset -n istio-system