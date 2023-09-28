#!/bin/bash

# Get the absolute path of the root directory of your git
DIR=$(git rev-parse --show-toplevel)

CLUSTERV4_NAME=ipv4
CLUSTERV4_CTX=kind-ipv4

CLUSTERV6_NAME=ipv6singlestack
CLUSTERV6_CTX=kind-ipv6singlestack

#istio version
HUB=docker.io/istio
TAG=1.18.3