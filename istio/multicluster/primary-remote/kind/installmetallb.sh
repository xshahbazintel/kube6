#!/bin/bash

. ../../config.sh

# download docker images to a host
echo "Pulling metallb images to a docker host..."
docker pull quay.io/metallb/controller:v0.13.10
docker pull quay.io/metallb/speaker:v0.13.10

# Load images to both clusters
echo "Loading metallb images to both clusters..."
kind load docker-image --name $CLUSTER7_NAME quay.io/metallb/controller:v0.13.10
kind load docker-image --name $CLUSTER7_NAME quay.io/metallb/controller:v0.13.10

kind load docker-image --name $CLUSTER8_NAME quay.io/metallb/speaker:v0.13.10
kind load docker-image --name $CLUSTER8_NAME quay.io/metallb/speaker:v0.13.10

# Install metallb using the latest version 13.10
echo "install metallb on $CLUSTER7_NAME..."
kubectl apply --context="${CLUSTER7_CTX}" -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml

echo "install metallb on $CLUSTER8_NAME..."
kubectl apply --context="${CLUSTER8_CTX}" -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml

# wait for metallb to get ready
echo "Wait 20 sec for metallb to get ready..."

sleep 20

#create metallb pool and L2 advertisment
echo "creating metallb l2 pool on $CLUSTER7_NAME..."
kubectl apply --context="${CLUSTER7_CTX}" -f - <<EOF
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.171-172.18.255.179
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: all-pools
  namespace: metallb-system
EOF

echo "creating metallb l2 pool on $CLUSTER8_NAME..."
kubectl apply --context="${CLUSTER8_CTX}" -f - <<EOF
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.181-172.18.255.189
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: all-pools
  namespace: metallb-system
EOF

