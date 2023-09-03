#!/bin/bash

. ../../config.sh

# prepare clustermesh
echo "Installing cilium-ca secret..."
kubectl --context $CLUSTER6_CTX delete secret cilium-ca -n kube-system
kubectl --context=$CLUSTER5_CTX get secret -n kube-system cilium-ca -o yaml | \
   kubectl --context $CLUSTER6_CTX create -f -

# enable clustermesh
echo "Enabling cilium clustermesh..."
cilium clustermesh enable --context $CLUSTER5_CTX --service-type LoadBalancer
cilium clustermesh enable --context $CLUSTER6_CTX --service-type LoadBalancer

cilium clustermesh status --context $CLUSTER5_CTX --wait
cilium clustermesh status --context $CLUSTER6_CTX --wait

# connect clusters
echo "Connecting cilium $CLUSTER5_NAME and $CLUSTER6_NAME..."
cilium clustermesh connect --context $CLUSTER5_CTX --destination-context $CLUSTER6_CTX
cilium clustermesh status --context $CLUSTER6_CTX --wait