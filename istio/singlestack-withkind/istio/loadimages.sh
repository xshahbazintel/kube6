#!/bin/bash

CLUSTER_NAME=ipv6singlestack
HUB=abasitt
TAG=abasitt

#load pilot and proxyv images
kind load docker-image --name $CLUSTER_NAME $HUB/pilot:$TAG
kind load docker-image --name $CLUSTER_NAME $HUB/proxyv2:$TAG