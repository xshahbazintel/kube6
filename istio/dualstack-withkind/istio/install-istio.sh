#!/bin/bash

# point this to your latest build binary
istioctl_latest=~/dev/istio/out/linux_amd64/istioctl

# Install istio ambient profile
echo "Installing istio..."
$istioctl_latest install -f iop_dual.yaml --skip-confirmation

# Verify that istio is installed
echo "Verifying istio installation..."
istioctl verify-install
# Verify that istio is installed
echo "Verifying istio pods and ds..."
kubectl get pods -n istio-system
kubectl get daemonset -n istio-system