#!/bin/bash

. ../../config.sh

echo "lock $CLUSTER4_NAME default ns using Cilium NetPol..."
kubectl --context="${CLUSTER4_CTX}" apply -f ../cilium/denydefault.yaml
# apply timeout for helloworld
kubectl --context="${CLUSTER3_CTX}" apply -f vs.yaml
kubectl --context="${CLUSTER4_CTX}" apply -f vs.yaml


echo "$CLUSTER3_NAME Eastwest Gateways LB IP address..."
echo $(kubectl \
    --context="${CLUSTER3_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "$CLUSTER4_NAME Eastwest Gateways LB IP address..."
echo $(kubectl \
    --context="${CLUSTER4_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "*************************"

echo "$CLUSTER3_NAME Sleep endpoints of helloworld..."
istioctl pc ep deploy/sleep -n default --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER3_CTX}"
echo "$CLUSTER4_NAME Sleep endpoints of helloworld..."
istioctl pc ep deploy/sleep -n default --cluster "outbound|5000||helloworld.default.svc.cluster.local" --context="${CLUSTER4_CTX}"

echo "*************************"

#load helloworld and sleep images
echo "Curl from cluster $CLUSTER3_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER3_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; sleep 1; done
#load helloworld and sleep images
echo "Curl from cluster $CLUSTER4_NAME sleep..."
for i in {1..6}; do kubectl --context="${CLUSTER4_CTX}" exec deploy/sleep -- curl -sS helloworld:5000/hello; sleep 1; done

echo "Remove $CLUSTER4_NAME default ns Cilium NetPol..."
kubectl --context="${CLUSTER4_CTX}" delete -f ../cilium/denydefault.yaml
# delete timeout for helloworld
kubectl --context="${CLUSTER3_CTX}" delete -f vs.yaml
kubectl --context="${CLUSTER4_CTX}" delete -f vs.yaml