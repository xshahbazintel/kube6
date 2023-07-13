#!/bin/bash

# test pods on a single stack ipv6 cluster and istio in single stack mode with a secondary ipv4 address, this is supposed to fail without excluding interface net1

# label namespace for injection
kubectl label ns default istio-injection=enabled --overwrite

# install a pod with unicast range ip address
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: pod-validunicast
  annotations:
    traffic.sidecar.istio.io/excludeInterfaces: net1
    k8s.v1.cni.cncf.io/networks: '[
            { "name": "macvlan-conf-static",
              "ips": [ "10.1.1.11/24" ] }
    ]'
spec:
  containers:
  - name: pod-validunicast
    command: ["/bin/ash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: alpine
EOF

# install pod with linklocal address
# install a pod with unicast range ip address
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: pod-linklocal
  annotations:
    traffic.sidecar.istio.io/excludeInterfaces: net1
    k8s.v1.cni.cncf.io/networks: '[
            { "name": "macvlan-conf-static",
              "ips": [ "169.254.1.11/24" ] }
    ]'
spec:
  containers:
  - name: pod-linklocal
    command: ["/bin/ash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: alpine
EOF