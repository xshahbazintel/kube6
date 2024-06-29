#!/bin/bash

# Invoke the kind script
source installkind.sh
# Wait for 10 sec
sleep 10

# Invoke the metallb script
source installmetallb.sh
# Wait for 5 sec
sleep 5