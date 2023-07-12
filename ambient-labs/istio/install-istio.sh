#!/bin/bash

# Install istio ambient profile
echo "Installing istio ambient profile..."
istioctl install --set profile=ambient --set components.ingressGateways[0].enabled=true --set components.ingressGateways[0].name=istio-ingressgateway --skip-confirmation

# Verify that istio is installed
echo "Verifying istio installation..."
istioctl verify-install
# Verify that istio is installed
echo "Verifying istio pods and ds..."
kubectl get pods -n istio-system
kubectl get daemonset -n istio-system