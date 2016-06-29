#!/bin/bash

function initMasterZones {
	echo "Creating Master Zone Configuration"
	for domain in $(ls /etc/bind/zones/)
	do
		named-checkzone $domain /etc/bind/zones/$domain
		if [ $? -ne 0 ]
		then
			exit 1;
		else
			echo -e "zone \"$domain\" {\n\ttype master;\n\tfile \"/etc/bind/zones/$domain\";\n\tallow-transfer { $BIND_SLAVE_IP; };\n};\n\n" >> /etc/bind/named.conf.local
		fi
	done

}

function initSlaveZones {

	for domain in $(ls /etc/bind/zones/)
	do
		echo "Creating $domain config"
		echo -e "zone \"$domain\" {\n\ttype slave;\n\tfile \"$domain\";\n\tmasters { $BIND_MASTER_IP; };\n\tnotify no;\n};\n\n" >> /etc/bind/named.conf.local
	done

}

	if [ "$BIND_MASTER" = "true" -a -n "$BIND_SLAVE_IP" ]
	then
		initMasterZones
	elif [ -n "$BIND_MASTER_IP" ]
	then
		initSlaveZones
	else
		echo "Missing required variables: BIND_MASTER==true+BIND_SLAVE_IP for master or BIND_MASTER_IP for slave"
		exit 1
	fi

	/usr/sbin/named -c /etc/bind/named.conf -4 -g
