#!/bin/bash

. ../../config.sh

# Delete the cluster with name ambient
echo "Deleting $CLUSTER3_NAME..."
kind delete cluster --name $CLUSTER3_NAME

echo "Deleting $CLUSTER4_NAME..."
kind delete cluster --name $CLUSTER4_NAME

# Verify that the cluster is deleted
echo "Verifying cluster deletion..."
kind get clusters

