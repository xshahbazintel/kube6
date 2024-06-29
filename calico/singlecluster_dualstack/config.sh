#!/bin/bash

# Get the absolute path of the root directory of your git
DIR=$(git rev-parse --show-toplevel)

#multi-network clusters
CLUSTER1_NAME=caldual



CLUSTER1_CTX=kind-clu1
CLUSTER2_CTX=kind-clu2


#istio version
HUB=docker.io/istio
TAG=1.18.2