FROM library/debian:jessie
MAINTAINER kenneth@floss.cat
RUN	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install -y bind9 && \
	rm -rf /var/lib/apt/lists/*
COPY bind.sh /
#	Separated layer 4 light upgrades
RUN	chmod +x /bind.sh
COPY named.conf.options /etc/bind/
ENV BIND_MASTER=true
EXPOSE 53 53/udp
ENTRYPOINT ["/bind.sh"]
