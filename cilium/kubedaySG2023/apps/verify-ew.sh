#!/bin/bash

. ../config.sh

echo "*************************"

echo "$CLUSTER1_NAME worker nodes..."
kubectl --context="${CLUSTER1_CTX}" get nodes -o custom-columns=NAME:.metadata.name,IP:.status.addresses[0].address

echo "*************************"

echo "$CLUSTER1_NAME worker route..."
docker exec clu1-worker ip -6 route

echo "*************************"

#load helloworld and sleep images
echo "Curl from cluster $CLUSTER1_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER1_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; done
#load helloworld and sleep images
echo "Curl from cluster $CLUSTER2_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER2_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; done