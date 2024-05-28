#!/bin/bash


# create net-attach-def
cat <<EOF | kubectl create -f -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan-conf-static
spec: 
  config: '{
            "cniVersion": "0.3.1",
            "plugins": [
                {
                    "type": "macvlan",
                    "capabilities": { "ips": true },
                    "master": "eth0",
                    "mode": "bridge",
                    "ipam": {
                        "type": "static"
                    }
                }, {
                    "type": "tuning"
                } ]
        }'
---
EOF

docker pull alpine
kind load docker-image --name cal61 alpine

# install a pod with a static ip
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: alpine1
  annotations:
    k8s.v1.cni.cncf.io/networks: '[
            { "name": "macvlan-conf-static",
              "ips": [ "10.1.1.12/24" ] }
    ]'
spec:
  containers:
  - name: alpine1
    command: ["/bin/ash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: alpine
    imagePullPolicy: IfNotPresent
EOF