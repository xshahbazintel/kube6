#!/bin/bash

# install multus
kubectl create -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml

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