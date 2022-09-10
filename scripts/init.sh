#!/bin/bash

while read line || [ -n "$line" ]; do 
parts=( $line )
if [[ ${parts[0]} != \#* ]]
then
	echo ${parts[2]} | saslpasswd2 -p -c -u ${parts[1]} ${parts[0]} -f /etc/sasldb2
fi
done < /opt/users.conf

cp /opt/sender_maps.conf /etc/postfix/sender_maps
postmap /etc/postfix/sender_maps

cat <<EOT > /etc/postfix/sasl/smtpd.conf
pwcheck_method: saslauthd
mech_list: PLAIN LOGIN 
EOT

cat <<EOT > /etc/postfix/main.cf
smtpd_banner = $myhostname ESMTP $mail_name
biff = no
append_dot_mydomain = no
readme_directory = no
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes
smtpd_tls_auth_only = yes
smtpd_tls_security_level=encrypt
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
relay_domains = labtagon.com
smtpd_sender_login_maps = hash:/etc/postfix/sender_maps
smtpd_sender_restrictions = reject_authenticated_sender_login_mismatch
smtpd_relay_restrictions = permit_sasl_authenticated reject
myhostname = localhost
mydestination = $myhostname
relayhost = ${RELAY_HOST}
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all
smtpd_sasl_auth_enable = yes
smtpd_sasl_path = smtpd
smtp_tls_security_level = encrypt
smtp_tls_mandatory_ciphers = high
EOT

mkdir -p /var/spool/postfix/var/run/saslauthd
saslauthd -c -m /var/spool/postfix/var/run/saslauthd -a sasldb

service rsyslog start
service postfix start
tail -F /var/log/mail.log