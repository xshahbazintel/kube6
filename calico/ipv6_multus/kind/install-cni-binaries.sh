#!/bin/bash

. ../config.sh

# download docker images to a host
echo "Pulling alpine image to a docker host..."
docker pull alpine

# Load images to both clusters
echo "Loading alpine image to both clusters..."
kind load docker-image --name $CLUSTER1_NAME alpine

# Install metallb using the latest version 13.10
echo "install cni binaries on $CLUSTER1_NAME..."
kubectl apply --context="${CLUSTER1_CTX}" -f cni-manifest.yaml

sleep 2

