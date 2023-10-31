#!/bin/bash

. ../../config.sh

echo "Block $CLUSTER8_NAME EastWest GW Port 15443 using Cilium NetPol..."
kubectl --context="${CLUSTER8_CTX}" apply -f ../cilium/deny15443.yaml
# apply timeout for helloworld
kubectl --context="${CLUSTER7_CTX}" apply -f vs.yaml
kubectl --context="${CLUSTER8_CTX}" apply -f vs.yaml


echo "$CLUSTER7_NAME Eastwest Gateways LB IP address..."
echo $(kubectl \
    --context="${CLUSTER7_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "$CLUSTER8_NAME Eastwest Gateways LB IP address..."
echo $(kubectl \
    --context="${CLUSTER8_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "*************************"

echo "$CLUSTER7_NAME Sleep endpoints of helloworld..."
istioctl pc ep deploy/sleep -n default --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER7_CTX}"
echo "$CLUSTER8_NAME Sleep endpoints of helloworld..."
istioctl pc ep deploy/sleep -n default --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER8_CTX}"

echo "*************************"

#load helloworld and sleep images
echo "Curl from cluster $CLUSTER7_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER7_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; sleep 1; done
#load helloworld and sleep images
echo "Curl from cluster $CLUSTER8_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER8_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; sleep 1; done

echo "Remove $CLUSTER8_NAME EastWest GW Port 15443 Cilium NetPol..."
kubectl --context="${CLUSTER8_CTX}" delete -f ../cilium/deny15443.yaml
# delete timeout for helloworld
kubectl --context="${CLUSTER7_CTX}" delete -f vs.yaml
kubectl --context="${CLUSTER8_CTX}" delete -f vs.yaml