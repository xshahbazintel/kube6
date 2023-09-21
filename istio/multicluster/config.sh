#!/bin/bash

# Get the absolute path of the root directory of your git
DIR=$(git rev-parse --show-toplevel)

#multi-network clusters
CLUSTER7_NAME=clu7
CLUSTER8_NAME=clu8

CLUSTER7_CTX=kind-clu7
CLUSTER8_CTX=kind-clu8

#istio version
HUB=docker.io/istio
TAG=1.18.2