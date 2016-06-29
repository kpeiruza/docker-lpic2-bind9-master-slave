FROM library/debian:jessie
MAINTAINER kenneth@floss.cat
RUN	debconf-set-selections < /tmp/debconf-ldap.txt && \
	rm /tmp/debconf-ldap.txt && \
	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install -y bind9 && \
	rm -rf /var/lib/apt/lists/*
COPY named.conf.options /etc/bind/
COPY bind.sh /
ENV BIND_MASTER=true
EXPOSE 53 53/udp
ENTRYPOINT ["/bind.sh"]
