# docker-lpic2-bind9-master-slave

*Objectives:*
- Serve pue.lan domain from DNS Master and configure it on both master and slave

*To run the master:*
- Create a folder with DNS zones. The filename MUST match the domainname ( i.e. pue.lan -> pue.lan )
- docker run -ti --name bindmaster -e BIND_MASTER=true -e BIND_SLAVE_IP=ALLOWED-AXFR-IP-OR-RANGE -v /path/to/your/zones/folder:/etc/bind/zones kpeiruza/lpic2-bind9-master-slave 
	Suggestion for testing: set 172.16.0.0/12 as BIND_SLAVE_IP so any container in the default docker network will be able to perform zone transfers.

*Run the slave:*
- docker run -ti --name bindslave -e BIND_MASTER_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' bindmaster) -v /path/to/your/zones/folder:/etc/bind/zones kpeiruza/lpic2-bind9-master-slave 

Once started, you can check the DNS resolution with host or dig pointing to the container's IP:

- Master IP: docker inspect -f '{{ .NetworkSettings.IPAddress }}' bindmaster
- Slave IP: docker inspect -f '{{ .NetworkSettings.IPAddress }}' bindslave

The secondary server doesn't actually need the full zones, in fact if you create a bunch of empty files with "touch", it will configure all those domains as secondary, as it makes no real usage of the contents on these files. Maybe I can change the behaviour in a future version so I pick the SOA's DNS to make it the value of the masters entry.
