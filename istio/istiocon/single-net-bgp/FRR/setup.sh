#!/bin/bash

# Invoke the frr setup script
source setup-frr.sh
# Wait for FRR to start
sleep 5

# Invoke the BGP peering setup script
source setup-bgp.sh
