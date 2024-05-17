#!/bin/bash

# Function to print a separator with a message
print_separator() {
    echo -e "\n\033[1m$1\033[0m"
    echo "────────────────────────────────────────"
}

# Check initial routes
print_separator "Initial BIRD Routes"
docker exec ubuntu1 birdc show route

# Add IP address and check routes
print_separator "Routes After IP Addition"
docker exec ubuntu1 ip -6 addr add fd00:1::22/64 dev eth0
sleep 2
docker exec ubuntu1 birdc show route

# Delete IP address and check routes
print_separator "Routes After IP Deletion"
docker exec ubuntu1 ip -6 addr del fd00:1::22/64 dev eth0
sleep 2
docker exec ubuntu1 birdc show route
