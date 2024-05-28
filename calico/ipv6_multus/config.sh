#!/bin/bash

# Get the absolute path of the root directory of your git
DIR=$(git rev-parse --show-toplevel)

#multi-network clusters
CLUSTER1_NAME=cal61



CLUSTER1_CTX=kind-cal61
CLUSTER2_CTX=kind-cal62


#istio version
HUB=docker.io/istio
TAG=1.22.0