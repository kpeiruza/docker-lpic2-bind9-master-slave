# docker-lpic2-bind9-master-slave

*Objectives:*
- Serve pue.lan domain from DNS Master and configure it on both master and slave

*To run the master:*
- Create a folder with DNS zones. The filename MUST match the domainname ( i.e. pue.lan -> pue.lan )
- docker run -ti --name bindmaster -e BIND_MASTER=true -e BIND_SLAVE_IP=ALLOWED-AXFR-IP-OR-RANGE -v /path/to/your/zones/folder:/etc/bind/zones kpeiruza/lpic2-bind9-master-slave 

*Run the slave:*
- docker run -ti --name bindslave -e BIND_MASTER_IP=$(docker inspect bindmaster -f '{{ .NetworkSettings.IPAddress }}') kpeiruza/lpic2-bind9-master-slave 

Once started, you can check the DNS resolution with host or dig pointing to the container's IP:

Master IP: docker inspect bindmaster -f '{{ .NetworkSettings.IPAddress }}'
Slave IP: docker inspect bindslave -f '{{ .NetworkSettings.IPAddress }}'
