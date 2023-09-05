#!/bin/bash

. ../../config.sh

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

echo "$CLUSTER3_NAME worker nodes..."
kubectl --context="${CLUSTER3_CTX}" get nodes -o custom-columns=NAME:.metadata.name,IP:.status.addresses[0].address

echo "*************************"

echo "$CLUSTER3_NAME worker route..."
docker exec clu3-worker ip route

echo "*************************"

echo "FRR routes..."
docker exec frr_kind vtysh \
    -c "show ip bgp summary" \
    -c "show ip route" \
    -c "exit"

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