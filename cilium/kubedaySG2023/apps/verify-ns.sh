#!/bin/bash

. ../config.sh


echo "*************************"

echo "$CLUSTER1_NAME Istio-ingress endpoints of helloworld..."
istioctl pc ep deploy/istio-ingressgateway -n istio-system --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER1_CTX}"

echo "*************************"

#load helloworld and sleep images
echo "Curl to $CLUSTER1_NAME istio-ingress..."
for i in {1..5}; do docker run --rm --net kind curlimages/curl sh -c 'curl -s [fc00:f853:ccd:e793:ffff:1:0:3]/hello'; done