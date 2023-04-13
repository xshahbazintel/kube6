Docker compose up

$ sudo docker compose up -d

Functionality
daemons, which needs to be enabled for some functionality to work.
configuration applied to the corresponding daemons

Modify the configuration files
$ sudo sed -i 's/bgpd=no/bgpd=yes/' /var/lib/docker/volumes/frr_frr_config/_data/daemons
$ sudo sed -i 's/bfdd=no/bfdd=yes/' /var/lib/docker/volumes/frr_frr_config/_data/daemons
$ touch /var/lib/docker/volumes/frr_frr_config/_data/vtysh.conf

Docker compose restart

$ sudo docker compose restart

credit: https://karneliuk.com/2022/09/building-high-available-web-services-open-source-load-balancing-based-on-haproxy-frr-and-origin-web-server-based-on-nginx-connected-to-arista-evpn-vxlan-part-2-configuration-and-validation/ 

