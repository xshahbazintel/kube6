#!/bin/bash

CLUSTER_NAME=ipv4
CLUSTER_CTX=kind-ipv4

# load tcp echo images to kind
echo "Pulling images to a docker host..."
docker pull docker.io/istio/tcp-echo-server:1.2

echo "Load images to kind clusters..."
kind load docker-image --name $CLUSTER_NAME docker.io/istio/tcp-echo-server:1.2
#kind load docker-image --name $CLUSTER1_NAME docker.io/istio/examples-helloworld-v2

echo "Install demo apps to kind clusters..."
kubectl --context="${CLUSTER_CTX}" label ns default istio-injection=enabled --overwrite
kubectl --context="${CLUSTER_CTX}" apply -f https://github.com/istio/istio/blob/master/samples/tcp-echo/tcp-echo-ipv4.yaml