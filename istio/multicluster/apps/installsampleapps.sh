#!/bin/bash

CLUSTER1_NAME=clu1
CLUSTER2_NAME=clu2
CLUSTER1_CTX=kind-clu1 
CLUSTER2_CTX=kind-clu2
HUB=docker.io/istio
TAG=1.18.1

#load helloworld and sleep images

echo "Pulling images to a docker host..."
docker pull docker.io/istio/examples-helloworld-v1
docker pull docker.io/istio/examples-helloworld-v2
docker pull curlimages/curl

echo "Load images to kind clusters..."
kind load docker-image --name $CLUSTER1_NAME docker.io/istio/examples-helloworld-v1
kind load docker-image --name $CLUSTER1_NAME docker.io/istio/examples-helloworld-v2
kind load docker-image --name $CLUSTER1_NAME curlimages/curl

kind load docker-image --name $CLUSTER2_NAME docker.io/istio/examples-helloworld-v1
kind load docker-image --name $CLUSTER2_NAME docker.io/istio/examples-helloworld-v2
kind load docker-image --name $CLUSTER2_NAME curlimages/curl


echo "Install demo apps to kind clusters..."
kubectl --context="${CLUSTER1_CTX}" label ns default istio-injection=enabled --overwrite
kubectl --context="${CLUSTER1_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml
#kubectl --context="${CLUSTER1_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml


kubectl --context="${CLUSTER2_CTX}" label ns default istio-injection=enabled --overwrite
kubectl --context="${CLUSTER2_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml
kubectl --context="${CLUSTER2_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml
