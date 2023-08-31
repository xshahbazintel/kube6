#!/bin/bash

# Bring up Docker Compose file
docker compose up -d

# Modify daemons file
sudo sed -i 's/bgpd=no/bgpd=yes/' /var/lib/docker/volumes/frr_frr_config/_data/daemons
sudo sed -i 's/bfdd=no/bfdd=yes/' /var/lib/docker/volumes/frr_frr_config/_data/daemons

# Create vtysh.conf file
touch /var/lib/docker/volumes/frr_frr_config/_data/vtysh.conf

# Restart Docker Compose file
docker compose restart
