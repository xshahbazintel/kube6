#!/bin/bash

# Check if a directory is provided as an argument, otherwise use /tmp
if [ -n "$1" ]; then
  DIR="$1"
else
  DIR="/tmp"
fi

# Generate a self-signed certificate and private key for nginx using openssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$DIR/nginx.key" -out "$DIR/nginx.crt" -subj "/CN=nginx.example.com" -addext "subjectAltName = DNS:nginx.example.com"

# Create a secret to store the certificate and key in Kubernetes
kubectl create secret tls nginx-example-tls --key "$DIR/nginx.key" --cert "$DIR/nginx.crt"

# Delete the certificate and key files from the directory
#rm "$DIR/nginx.key" "$DIR/nginx.crt"
