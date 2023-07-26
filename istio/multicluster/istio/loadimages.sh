#!/bin/bash

CLUSTER_NAME=ipv4single
HUB=docker.io/istio
TAG=1.18.1

if [ "$1" == "istio" ]; then
    # Load Istio images
    kind load docker-image --name $CLUSTER_NAME $HUB/pilot:$TAG
    kind load docker-image --name $CLUSTER_NAME $HUB/proxyv2:$TAG
    echo "Istio images loaded."
elif [ "$1" == "httpbin" ]; then
    TAG=latest
    # Load HTTPBin image
    kind load docker-image --name $CLUSTER_NAME docker.io/kong/httpbin:$TAG
    echo "HTTPBin image loaded."
else
    echo "Please provide a valid option: 'istio' or 'httpbin'."
    exit 1
fi

echo "Image loading completed."