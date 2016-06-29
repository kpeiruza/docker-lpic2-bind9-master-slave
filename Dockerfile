FROM library/debian:jessie
MAINTAINER kenneth@floss.cat
COPY bind.sh /
RUN	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install -y bind9 && \
	rm -rf /var/lib/apt/lists/* && \
	chmod +x /bind.sh
COPY named.conf.options /etc/bind/
ENV BIND_MASTER=true
EXPOSE 53 53/udp
ENTRYPOINT ["/bind.sh"]
