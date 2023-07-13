#!/bin/bash

# Delete the cluster with name ambient
echo "Deleting cluster ambient..."
kind delete cluster --name ambient

# Verify that the cluster is deleted
echo "Verifying cluster deletion..."
kind get clusters

