#!/bin/bash
. ../config.sh


# download docker images to a host
echo "Pulling metallb images to a docker host..."
docker pull quay.io/metallb/controller:v0.13.10
docker pull quay.io/metallb/speaker:v0.13.10

# Load images to both clusters
echo "Loading metallb images to both clusters..."
kind load docker-image --name $CLUSTER_NAME quay.io/metallb/controller:v0.13.10
kind load docker-image --name $CLUSTER_NAME quay.io/metallb/speaker:v0.13.10

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
  - 172.18.254.11-172.18.254.20
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: all-pools
  namespace: metallb-system
EOF
