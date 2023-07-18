#!/bin/bash

CLUSTER_NAME=ipv4single
HUB=docker.io/istio
TAG=1.18.1

#load pilot and proxyv images
kind load docker-image --name $CLUSTER_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER_NAME $HUB/proxyv2:$TAG