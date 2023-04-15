#!/bin/bash

set -E

# Specify the IPv6 addresses in an array
peers=("${PEERS[@]}")

local_as=$LOCAL_AS

remote_as=$REMOTE_AS

docker exec frr01 vtysh \
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
    docker exec frr01 vtysh \
    -c "configure terminal" \
    -c "router bgp $local_as" \
    -c "neighbor $addr remote-as $remote_as" \
    -c "address-family $family unicast" \
    -c "neighbor $addr activate" \
    -c "end" \
    -c "exit"
done

#save the configuration
docker exec frr01 vtysh \
    -c "write" \
    -c "exit"