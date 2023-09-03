#!/bin/bash

. ../../config.sh

#load helloworld and sleep images

echo "Pulling images to a docker host..."
docker pull docker.io/istio/examples-helloworld-v1
docker pull docker.io/istio/examples-helloworld-v2
docker pull docker.io/kong/httpbin
docker pull curlimages/curl

echo "Load images to kind clusters..."
kind load docker-image --name $CLUSTER3_NAME docker.io/istio/examples-helloworld-v1
kind load docker-image --name $CLUSTER3_NAME docker.io/istio/examples-helloworld-v2
kind load docker-image --name $CLUSTER3_NAME curlimages/curl
#kind load docker-image --name $CLUSTER3_NAME docker.io/kong/httpbin

kind load docker-image --name $CLUSTER4_NAME docker.io/istio/examples-helloworld-v1
kind load docker-image --name $CLUSTER4_NAME docker.io/istio/examples-helloworld-v2
kind load docker-image --name $CLUSTER4_NAME curlimages/curl
#kind load docker-image --name $CLUSTER4_NAME docker.io/kong/httpbin

echo "Install demo apps to kind clusters..."
kubectl --context="${CLUSTER3_CTX}" label ns default istio-injection=enabled --overwrite
kubectl --context="${CLUSTER3_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml
kubectl --context="${CLUSTER3_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml -l service=helloworld
kubectl --context="${CLUSTER3_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml -l version=v1


kubectl --context="${CLUSTER4_CTX}" label ns default istio-injection=enabled --overwrite
kubectl --context="${CLUSTER4_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml
kubectl --context="${CLUSTER4_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml -l service=helloworld
kubectl --context="${CLUSTER4_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml -l version=v2
#kubectl --context="${CLUSTER4_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/httpbin/httpbin.yaml 