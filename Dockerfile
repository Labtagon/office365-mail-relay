FROM ubuntu:16.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -q -y postfix ca-certificates mailutils rsyslog cyrus-admin cyrus-clients sasl2-bin 

COPY ./scripts/init.sh /opt/init.sh
COPY ./conf/sender_maps.conf /opt/sender_maps.conf
COPY ./conf/users.conf /opt/users.conf

EXPOSE 25

CMD ["/opt/init.sh"]



