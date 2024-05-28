#!/bin/bash

. ../config.sh

# download istio images to a host
echo "Pulling istio images to a docker host..."
docker pull $HUB/pilot:$TAG
docker pull $HUB/proxyv2:$TAG
docker pull $HUB/ztunnel:$TAG
docker pull $HUB/install-cni:$TAG

echo "load istio images to the clusters..."
kind load docker-image --name $CLUSTER1_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER1_NAME $HUB/proxyv2:$TAG
kind load docker-image --name $CLUSTER1_NAME $HUB/ztunnel:$TAG
kind load docker-image --name $CLUSTER1_NAME $HUB/install-cni:$TAG


# Install istio iop profile on cluster1
echo "Installing istio in $CLUSTER1_NAME..."
istioctl install --set profile=ambient  --skip-confirmation
