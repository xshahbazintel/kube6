#!/bin/bash

. ../config.sh

# prepare clustermesh
echo "Installing cilium-ca secret..."
kubectl --context $CLUSTER2_CTX delete secret cilium-ca -n kube-system
kubectl --context=$CLUSTER1_CTX get secret -n kube-system cilium-ca -o yaml | \
   kubectl --context $CLUSTER2_CTX create -f -

# enable clustermesh
echo "Enabling cilium clustermesh..."
cilium clustermesh enable --context $CLUSTER1_CTX --service-type LoadBalancer
cilium clustermesh enable --context $CLUSTER2_CTX --service-type LoadBalancer

cilium clustermesh status --context $CLUSTER1_CTX --wait
cilium clustermesh status --context $CLUSTER2_CTX --wait

# connect clusters
echo "Connecting cilium $CLUSTER1_NAME and $CLUSTER2_NAME..."
cilium clustermesh connect --context $CLUSTER1_CTX --destination-context $CLUSTER2_CTX
cilium clustermesh status --context $CLUSTER2_CTX --wait