#!/bin/bash
. ../config.sh


# Run the bash script with the directory as an argument
#./create-cert.sh "$DIR"
#providing no dir so the certs are thrown in the /tmp and won't be deleted
./create-cert.sh

# load tcp echo images to kind
echo "Pulling images to a docker host..."
docker pull nginx:1.25.1-alpine
docker pull curlimages/curl

echo "Load images to kind clusters..."
kind load docker-image --name $CLUSTER_NAME docker.io/istio/tcp-echo-server:1.2
kind load docker-image --name $CLUSTER_NAME curlimages/curl

echo "Install demo apps to kind clusters..."
kubectl --context="${CLUSTER_CTX}" label ns default istio-injection=enabled --overwrite
kubectl create configmap nginx-conf --from-file=nginx.conf
kubectl apply -f nginx.yaml

