#!/bin/bash
#	GPL, of course, 
#	Main config file when calling named
configCore="/etc/bind/named.conf"
#	Where to write TSIG and zones configuration
configCustom="/etc/bind/named.conf.local"

function initMasterZones {

	echo "Creating Master Zone Configuration"
	for domain in $(ls /etc/bind/zones/)
	do
		named-checkzone $domain /etc/bind/zones/$domain
		if [ $? -ne 0 ]
		then
			exit 1;
		else
			if [ -n "$BIND_SLAVE_IP" ]
			then
#	IP AUTH MODE
				echo -e "zone \"$domain\" {\n\ttype master;\n\tfile \"/etc/bind/zones/$domain\";\n\tallow-transfer { $BIND_SLAVE_IP; };\n};\n\n" >> $configCustom
			else
#	Defaults to docker0. We don't want everyone to be able to perform AXFR!
				echo -e "zone \"$domain\" {\n\ttype master;\n\tfile \"/etc/bind/zones/$domain\";\n\tallow-transfer { 172.16.0.0/12; };\n};\n\n" >> $configCustom
			fi
		fi
	done

}

function initSlaveZones {

	for domain in $(ls /etc/bind/zones/)
	do
		echo "Creating $domain config"
		echo -e "zone \"$domain\" {\n\ttype slave;\n\tfile \"$domain\";\n\tmasters { $BIND_MASTER_IP; };\n\tnotify no;\n};\n\n" >> $configCustom
	done

}

if [ "$BIND_MASTER" = "true" ]
then
	initMasterZones
elif [ -n "$BIND_MASTER_IP" ]
then
	initSlaveZones
else
	echo "Missing required variables: BIND_MASTER==true+BIND_SLAVE_IP for master or BIND_MASTER_IP for slave"
	exit 1
fi

/usr/sbin/named -c $configCore -4 -g
