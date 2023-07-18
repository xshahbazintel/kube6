#!/bin/bash

# Install metallb using the latest version 0.14
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-frr.yaml

# Wait for all pods ready in metallb ns
kubectl wait --for=condition=Ready pod --all -n metallb-system --timeout=60s

#create metallb pool and L2 advertisment
kubectl apply -f - <<EOF
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.1-172.18.255.10
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: all-pools
  namespace: metallb-system
EOF
