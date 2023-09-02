#!/bin/bash

. ../../config.sh

# configure cilium bgp
echo "Configuring bgp in $CLUSTER1_NAME..."
kubectl --context="${CLUSTER3_CTX}" label nodes --all bgp-policy=istio
kubectl --context="${CLUSTER3_CTX}" apply -f bgp-clu3.yaml

# configure cilium bgp
echo "Configuring bgp in $CLUSTER4_NAME..."
kubectl --context="${CLUSTER4_CTX}" label nodes --all bgp-policy=istio
kubectl --context="${CLUSTER4_CTX}" apply -f bgp-clu4.yaml