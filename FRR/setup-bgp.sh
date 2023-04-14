#!/bin/bash

set -e

# Specify the IPv6 addresses in an array
ipv6_addrs=(
    "fd74:ca9b:3a09:868c:10:9:65:1"
    "fd74:ca9b:3a09:868c:10:9:65:2"
)

local_as=65100

remote_as=64500

docker exec frr01 vtysh \
    -c "configure terminal" \
    -c "router bgp $local_as" \
    -c "no bgp ebgp-requires-policy" \
    -c "no bgp default ipv4-unicast" \
    -c "no bgp network import-check" \
    -c "end" \
    -c "exit"

for addr in "${ipv6_addrs[@]}"
do
    # Configure BGP peering using the current IPv6 address and remote AS
    docker exec frr01 vtysh \
    -c "configure terminal" \
    -c "router bgp $local_as" \
    -c "neighbor $addr remote-as $remote_as" \
    -c "address-family ipv6 unicast" \
    -c "neighbor $addr activate" \
    -c "end" \
    -c "write" \
    -c "exit"
done
