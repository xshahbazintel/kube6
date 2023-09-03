#!/bin/bash

. ../../config.sh

# download istio images to a host
echo "Pulling istio images to a docker host..."
docker pull $HUB/pilot:$TAG
docker pull $HUB/proxyv2:$TAG

echo "load istio images to the clusters..."
kind load docker-image --name $CLUSTER3_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER3_NAME $HUB/proxyv2:$TAG

kind load docker-image --name $CLUSTER4_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER4_NAME $HUB/proxyv2:$TAG

# point this to your latest build binary
istioctl_latest=/usr/local/bin/istioctl

# install certs in both clusters
kubectl create namespace istio-system --context=${CLUSTER3_CTX}
kubectl create secret generic cacerts -n istio-system \
      --from-file=certs/cluster1/ca-cert.pem \
      --from-file=certs/cluster1/ca-key.pem \
      --from-file=certs/cluster1/root-cert.pem \
      --from-file=certs/cluster1/cert-chain.pem \
      --context=${CLUSTER3_CTX}

kubectl create namespace istio-system --context=${CLUSTER4_CTX}
kubectl create secret generic cacerts -n istio-system \
      --from-file=certs/cluster2/ca-cert.pem \
      --from-file=certs/cluster2/ca-key.pem \
      --from-file=certs/cluster2/root-cert.pem \
      --from-file=certs/cluster2/cert-chain.pem \
      --context=${CLUSTER4_CTX}

# Install istio iop profile on cluster3
echo "Installing istio in $CLUSTER3_NAME..."
istioctl --context="${CLUSTER3_CTX}" install -f iop-clu1.yaml --skip-confirmation

# Install istio profile on cluster4
echo "Installing istio in $CLUSTER4_NAME..."
istioctl --context="${CLUSTER4_CTX}" install -f iop-clu2.yaml --skip-confirmation

## fetch cluster2 controlplan address
#SERVER_CLU2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' clu2-control-plane)

# Enable Endpoint Discovery
echo "Enable Endpoint Discovery..."
istioctl x create-remote-secret \
    --context="${CLUSTER4_CTX}" \
    --name=cluster4 \
    --server=https://clu4-control-plane:6443 | \
    kubectl apply -f - --context="${CLUSTER3_CTX}"

istioctl x create-remote-secret \
    --context="${CLUSTER3_CTX}" \
    --name=cluster3 \
    --server=https://clu3-control-plane:6443 | \
    kubectl apply -f - --context="${CLUSTER4_CTX}"
