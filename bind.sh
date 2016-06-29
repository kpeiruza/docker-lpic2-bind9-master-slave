#!/bin/bash
#	Main config file when calling named
configCore="/etc/bind/named.conf"
#	Where to write TSIG and zones configuration
configCustom="/etc/bind/named.conf.local"

function initTSIG {
	echo "Creating TSIG Configuration"
#	ACL defining ranges where we want to use our TSIG key
#	We define 172.16.0.0/12; here as all IP's assigned by default
#	by docker will probably be inside 172.17.X.Y or 172.18.X.Y
	echo 'acl remotepeers {
	172.16.0.0/12;' >> $configCustom
#	Additional IPs just in case they were defined
	if [ -n "$BIND_MASTER_IP" ]
	then
		echo "$BIND_MASTER_IP;" >> $configCustom
	fi
	if [ -n "$BIND_SLAVE_IP" ]
	then
		echo "$BIND_SLAVE_IP;" >> $configCustom
	fi
#	End of TSIG stuff after next echo
	echo '
};

key "interconecta" {
	algorithm hmac-sha512;
	secret "xN4RtMWnEq6/nsyfvZZ2E8zfi2jYqRjnQhhKUe1vPQgAExlYYNMDkABtAIGZt/51TKbY0Wwjld97VdbNRcIUAg==";
};

server remotepeers {
	keys { interconecta; };
};

' | sed -e "s/BIND_SLAVE_IP;/$BIND_SLAVE_IP;/g" -e "s/BIND_MASTER_IP;/$BIND_MASTER_IP;/g" | grep -v "^\t;$" >> $configCustom

}

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
#	TSIG AUTH MODE
				echo -e "zone \"$domain\" {\n\ttype master;\n\tfile \"/etc/bind/zones/$domain\";\n\tallow-transfer { key interconecta; };\n};\n\n" >> $configCustom
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
	initTSIG
	initMasterZones
elif [ -n "$BIND_MASTER_IP" ]
then
	initTSIG
	initSlaveZones
else
	echo "Missing required variables: BIND_MASTER==true+BIND_SLAVE_IP for master or BIND_MASTER_IP for slave"
	exit 1
fi

/usr/sbin/named -c $configCore -4 -g
