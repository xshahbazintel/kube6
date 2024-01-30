#!/bin/bash

# Get the absolute path of the root directory of your git
DIR=$(git rev-parse --show-toplevel)

CLUSTER_NAME=ipv4
CLUSTER_CTX=kind-ipv4

#istio version
HUB=docker.io/istio
TAG=1.19.6