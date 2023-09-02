#!/bin/bash

. ../../config.sh

# prepare clustermesh
echo "Installing cilium-ca secret..."
kubectl --context $CLUSTER4_CTX delete secret cilium-ca -n kube-system
kubectl --context=$CLUSTER3_CTX get secret -n kube-system cilium-ca -o yaml | \
   kubectl --context $CLUSTER4_CTX create -f -

# enable clustermesh
echo "Enabling cilium clustermesh..."
cilium clustermesh enable --context $CLUSTER3_CTX --service-type LoadBalancer
cilium clustermesh enable --context $CLUSTER4_CTX --service-type LoadBalancer

cilium clustermesh status --context $CLUSTER3_CTX --wait
cilium clustermesh status --context $CLUSTER4_CTX --wait

# connect clusters
echo "Connecting cilium $CLUSTER3_NAME and $CLUSTER4_NAME..."
cilium clustermesh connect --context $CLUSTER3_CTX --destination-context $CLUSTER4_CTX
cilium clustermesh status --context $CLUSTER4_CTX --wait