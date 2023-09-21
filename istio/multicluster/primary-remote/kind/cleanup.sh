#!/bin/bash

. ../../config.sh

# Delete the cluster with name ambient
echo "Deleting $CLUSTER7_NAME..."
kind delete cluster --name $CLUSTER7_NAME

echo "Deleting $CLUSTER8_NAME..."
kind delete cluster --name $CLUSTER8_NAME

# Verify that the cluster is deleted
echo "Verifying cluster deletion..."
kind get clusters

