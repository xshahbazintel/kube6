#!/bin/bash

# Get the absolute path of the root directory of your git
DIR=$(git rev-parse --show-toplevel)

#multi-network clusters
CLUSTER1_NAME=clu1
CLUSTER2_NAME=clu2
CLUSTER1_CTX=kind-clu1
CLUSTER2_CTX=kind-clu2
CTX_CLUSTER1=kind-clu1
CTX_CLUSTER2=kind-clu2

#istio version
HUB=docker.io/istio
TAG=1.18.2