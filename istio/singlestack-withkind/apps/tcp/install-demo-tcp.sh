#!/bin/bash
. ../config.sh

# load tcp echo images to kind
echo "Pulling images to a docker host..."
docker pull docker.io/istio/tcp-echo-server:1.2
docker pull curlimages/curl

echo "Load images to kind clusters..."
kind load docker-image --name $CLUSTER_NAME docker.io/istio/tcp-echo-server:1.2
kind load docker-image --name $CLUSTER_NAME curlimages/curl

echo "Install demo apps to kind clusters..."
kubectl --context="${CLUSTER_CTX}" label ns default istio-injection=enabled --overwrite
kubectl --context="${CLUSTER_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/tcp-echo/tcp-echo.yaml
kubectl --context="${CLUSTER_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml