#!/bin/bash
. ../../config.sh

KEYCLOAK_VERSION="22.0.1"
YAML_URL="https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/latest/kubernetes/keycloak.yaml"


# load tcp echo images to kind
echo "Pulling images to a docker host..."
docker pull quay.io/keycloak/keycloak:$KEYCLOAK_VERSION
docker pull curlimages/curl

echo "Load images to kind clusters..."
kind load docker-image --name $CLUSTER_NAME quay.io/keycloak/keycloak:$KEYCLOAK_VERSION
kind load docker-image --name $CLUSTER_NAME curlimages/curl

echo "Install demo apps to kind clusters..."
kubectl --context="${CLUSTER_CTX}" label ns default istio-injection=enabled --overwrite
kubectl --context="${CLUSTER_CTX}" apply -f https://raw.githubusercontent.com/istio/istio/master/samples/sleep/sleep.yaml
curl -s "$YAML_URL" | awk -v version="$KEYCLOAK_VERSION" '{gsub("\\$\\$VERSION\\$\\$", version)}1' | kubectl --context="${CLUSTER_CTX}" create -f -
