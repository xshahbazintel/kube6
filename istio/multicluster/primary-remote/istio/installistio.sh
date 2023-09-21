#!/bin/bash

. ../../config.sh

# download istio images to a host
echo "Pulling istio images to a docker host..."
docker pull $HUB/pilot:$TAG
docker pull $HUB/proxyv2:$TAG

echo "load istio images to the clusters..."
kind load docker-image --name $CLUSTER7_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER7_NAME $HUB/proxyv2:$TAG

kind load docker-image --name $CLUSTER8_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER8_NAME $HUB/proxyv2:$TAG

# point this to your latest build binary
istioctl_latest=/usr/local/bin/istioctl

# Install istio iop profile on CLUSTER7
echo "Installing istio in $CLUSTER7_NAME..."
kubectl create namespace istio-system --context=${CLUSTER7_CTX}
kubectl --context="${CLUSTER7_CTX}" label namespace istio-system topology.istio.io/network=network1
istioctl --context="${CLUSTER7_CTX}" install --set values.pilot.env.EXTERNAL_ISTIOD=true -f iop-clu7.yaml --skip-confirmation

echo "expose the controlplane in $CLUSTER7_NAME..."
kubectl --context="${CLUSTER7_CTX}" apply -n istio-system -f https://raw.githubusercontent.com/istio/istio/master/samples/multicluster/expose-istiod.yaml

echo "expose services in $CLUSTER7_NAME..."
kubectl --context="${CLUSTER7_CTX}" apply -n istio-system -f https://raw.githubusercontent.com/istio/istio/master/samples/multicluster/expose-services.yaml

# Install istio profile on CLUSTER8
echo "Installing istio in $CLUSTER8_NAME..."
kubectl create namespace istio-system --context=${CLUSTER8_CTX}
kubectl --context="${CLUSTER8_CTX}" annotate namespace istio-system topology.istio.io/controlPlaneClusters=cluster7 --overwrite
kubectl --context="${CLUSTER8_CTX}" label namespace istio-system topology.istio.io/network=network2 --overwrite

#Save the address of CLUSTER7’s east-west gateway.
export DISCOVERY_ADDRESS=$(kubectl \
    --context="${CLUSTER7_CTX}" \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

istioctl --context="${CLUSTER8_CTX}" install -y -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: remote
  values:
    istiodRemote:
      injectionPath: /inject/cluster/cluster8/net/network2
    global:
      remotePilotAddress: ${DISCOVERY_ADDRESS}
EOF


# Enable Endpoint Discovery
#echo "Enable Endpoint Discovery..."
#istioctl x create-remote-secret \
#    --context="${CLUSTER8_CTX}" \
#    --name=CLUSTER8 \
#    --server=https://clu2-control-plane:6443 | \
#    kubectl apply -f - --context="${CLUSTER7_CTX}"

echo "share remote-secret of cluster8 with cluster7..."
istioctl create-remote-secret \
    --context="${CLUSTER8_CTX}" \
    --name=cluster8 \
    --server=https://clu8-control-plane:6443 | \
    kubectl apply -f - --context="${CLUSTER7_CTX}"

echo "installing EW gateway in cluster8..."
istioctl --context="${CLUSTER8_CTX}" install -y -f iop-clu8.yaml

echo "expose services in $CLUSTER8_NAME..."
kubectl --context="${CLUSTER8_CTX}" apply -n istio-system -f https://raw.githubusercontent.com/istio/istio/master/samples/multicluster/expose-services.yaml