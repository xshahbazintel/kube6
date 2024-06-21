#!/bin/bash

. ../config.sh

echo "Installing Istio gateway, VS and SE..."
kubectl --context="${CLUSTER1_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld-gateway.yaml
kubectl --context="${CLUSTER1_CTX}" apply -f se-helloworld-global.yaml