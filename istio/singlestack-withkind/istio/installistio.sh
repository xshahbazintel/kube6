#!/bin/bash

CLUSTER_NAME=ipv4
CLUSTER_CTX=kind-ipv4
HUB=docker.io/istio
TAG=1.18.1

# Download images to a docker host
echo "Pulling images to a docker host..."
docker pull $HUB/pilot:$TAG
docker pull $HUB/proxyv2:$TAG

# Load Images to a kind cluster
echo "Loading images to a $CLUSTER_CTX..."
kind load docker-image --name $CLUSTER_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER_NAME $HUB/proxyv2:$TAG
echo "Istio images loaded."

# point this to your latest build binary
istioctl_latest=/usr/local/bin/istioctl

# Install istio ambient profile
echo "Installing istio..."
$istioctl_latest install -f iop.yaml --skip-confirmation

# Verify that istio is installed
echo "Verifying istio installation..."
istioctl verify-install
# Verify that istio is installed
#echo "Verifying istio pods and ds..."
#kubectl get pods -n istio-system
#kubectl get daemonset -n istio-system