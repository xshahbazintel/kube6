#!/bin/bash

set -E

declare -a peers

#clu3 peers
while IFS= read -r node; do
  # get the IP address of the node using docker inspect
  ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$node")
  # append the IP address to the array
  peers+=("$ip")
done < <(kind get nodes --name clu3)

# print the array elements
echo "${peers[@]}"

export LOCAL_AS=65100
export REMOTE_AS=64503

local_as=$LOCAL_AS

remote_as=$REMOTE_AS

docker exec frr_kind vtysh \
    -c "configure terminal" \
    -c "router bgp $local_as" \
    -c "no bgp ebgp-requires-policy" \
    -c "no bgp default ipv4-unicast" \
    -c "no bgp network import-check" \
    -c "end" \
    -c "exit"

for addr in "${peers[@]}"
do
    # Determine the IP address family of the peer
    if [[ $addr == *:* ]]; then
      family="ipv6"
    else
      family="ipv4"
    fi

    # Configure BGP peering using the current IPv6 address and remote AS
    docker exec frr_kind vtysh \
    -c "configure terminal" \
    -c "router bgp $local_as" \
    -c "neighbor $addr remote-as $remote_as" \
    -c "address-family $family unicast" \
    -c "neighbor $addr activate" \
    -c "end" \
    -c "exit"
done

#save the configuration
docker exec frr_kind vtysh \
    -c "write" \
    -c "exit"