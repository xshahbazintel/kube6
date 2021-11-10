# kube6
This repo contains files to deploy kubernetes using IPV6 only with Kubeadm. 
You can find calico version 3.20 tested and working with IPV6 only Kubernetes cluster version v1.22.3

Important!
Don't forget to update pod CIDR. According to calico documentation, it is not required with kubeadm but the cluster doesn't work properly without specifying the exact CIDR of your own cluster.
