#!/bin/bash

. ../../config.sh

# download istio images to a host
echo "Pulling istio images to a docker host..."
docker pull $HUB/pilot:$TAG
docker pull $HUB/proxyv2:$TAG

echo "load istio images to the clusters..."
kind load docker-image --name $CLUSTER5_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER5_NAME $HUB/proxyv2:$TAG

kind load docker-image --name $CLUSTER6_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER6_NAME $HUB/proxyv2:$TAG

# point this to your latest build binary
istioctl_latest=/usr/local/bin/istioctl

# install certs in both clusters
kubectl create namespace istio-system --context=${CLUSTER5_CTX}
kubectl create secret generic cacerts -n istio-system \
      --from-file=certs/cluster1/ca-cert.pem \
      --from-file=certs/cluster1/ca-key.pem \
      --from-file=certs/cluster1/root-cert.pem \
      --from-file=certs/cluster1/cert-chain.pem \
      --context=${CLUSTER5_CTX}

kubectl create namespace istio-system --context=${CLUSTER6_CTX}
kubectl create secret generic cacerts -n istio-system \
      --from-file=certs/cluster2/ca-cert.pem \
      --from-file=certs/cluster2/ca-key.pem \
      --from-file=certs/cluster2/root-cert.pem \
      --from-file=certs/cluster2/cert-chain.pem \
      --context=${CLUSTER6_CTX}

# Install istio iop profile on cluster5
echo "Installing istio in $CLUSTER5_NAME..."
istioctl --context="${CLUSTER5_CTX}" install -f iop-clu1.yaml --skip-confirmation

# Install istio profile on cluster6
echo "Installing istio in $CLUSTER6_NAME..."
istioctl --context="${CLUSTER6_CTX}" install -f iop-clu2.yaml --skip-confirmation

## fetch cluster2 controlplan address
#SERVER_CLU2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' clu2-control-plane)

# Enable Endpoint Discovery
echo "Enable Endpoint Discovery..."
istioctl x create-remote-secret \
    --context="${CLUSTER6_CTX}" \
    --name=cluster6 \
    --server=https://clu6-control-plane:6443 | \
    kubectl apply -f - --context="${CLUSTER5_CTX}"

istioctl x create-remote-secret \
    --context="${CLUSTER5_CTX}" \
    --name=cluster5 \
    --server=https://clu5-control-plane:6443 | \
    kubectl apply -f - --context="${CLUSTER6_CTX}"
