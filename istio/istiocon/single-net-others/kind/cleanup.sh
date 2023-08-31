#!/bin/bash

. ../../config.sh

# Delete the cluster with name ambient
echo "Deleting $CLUSTER5_NAME..."
kind delete cluster --name $CLUSTER5_NAME

echo "Deleting $CLUSTER6_NAME..."
kind delete cluster --name $CLUSTER6_NAME

# Verify that the cluster is deleted
echo "Verifying cluster deletion..."
kind get clusters

