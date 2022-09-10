This container uses postfix and a crippled Cyrus SASL setup to accept mails using basic auth (STARTTLS+LOGIN) and
forwarding them to Office365 Exchange Online, circumventing the basic auth ban ruled by Microsoft 
(https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/deprecation-of-basic-authentication-exchange-online)
and accepting custom credentials using a bind mount secret.

In order to setup this, you need a static public ip, whitelisting it as relay in Office365 Exchange Online.
https://lazyadmin.nl/office-365/smtp-relay-in-office-365/

Set the environment variable RELAY_HOST to the fqdn of your Exchange Online server (something.mail.protection.outlook.com).

This relay reads the username & password to authenticate to itself in a seperate user.conf file in the format:
```
#username      #domain          #password
no-reply       labtagon.com     somePassword
```

Additionally there is a constraint on what logins can use which sender e-mail, configured in sender_maps.conf, 
since no restriction is taking place on the Exchange Online side. This means all e-mail addresses can be used as a sender.
As a bonus this allows you to send mails from e-mail addresses of shared mailboxes, skipping the need for a licensed mailbox.
```
#sender mail                  #username and domain
no-reply@labtagon.com         no-reply@labtagon.com
allowed-sender@labtagon.com   no-reply@labtagon.com
```

In order to safely use this container you should bind mount your certificate pair, for testing purpose you could skip certificate checks in the smtp client.
You could setup certbot and target the renewhook at the runscript, restarting the container when obtaining a new certificate.

```
docker run -p 25:25 -d --restart always --name mail-relay \
-e RELAY_HOST=labtagon-com.mail.protection.outlook.com \
-v /etc/letsencrypt/live/mydomain/fullchain.pem:/etc/ssl/certs/ssl-cert-snakeoil.pem \
-v /etc/letsencrypt/live/mydomain/privkey.pem /etc/ssl/private/ssl-cert-snakeoil.key \
office365-mail-relay
```

On Ubuntu you might want to test your smtp setup using snail. Make sure to drop *ssl-verify=ignore* in a production test.
```
sudo apt-get install s-nail

echo "test" | s-nail  -r "allowed-sender@labtagon.com" \
-s "This is the subject" \
-S smtp="localhost:25" \
-S smtp-use-starttls \
-S smtp-auth=login \
-S smtp-auth-user="no-reply@labtagon.com" \
-S smtp-auth-password="somePassword" \
-S ssl-verify=ignore \
recipient@somewhere.com
 ```
