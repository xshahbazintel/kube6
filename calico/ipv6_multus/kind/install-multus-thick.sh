. ../config.sh

# download docker images to a host
echo "Pulling multus images to a docker host..."
docker pull ghcr.io/k8snetworkplumbingwg/multus-cni:v4.0.2-thick
#docker pull ghcr.io/k8snetworkplumbingwg/multus-cni:v4.0.2-thick

# Load images to both clusters
echo "Loading alpine image to both clusters..."
kind load docker-image --name $CLUSTER1_NAME ghcr.io/k8snetworkplumbingwg/multus-cni:v4.0.2-thick
#kind load docker-image --name $CLUSTER1_NAME ghcr.io/k8snetworkplumbingwg/multus-cni:v4.0.2-thick

# Install multus thin plugin
echo "install multus thin plugin on $CLUSTER1_NAME..."
kubectl --context kind-$CLUSTER1_NAME apply -k multus-thick/overlay-ipv6

sleep 2
