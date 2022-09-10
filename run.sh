#!/bin/bash
docker rm -f mail-relay
docker run -p 25:25 -d --restart always --name mail-relay \
-e RELAY_HOST=labtagon-com.mail.protection.outlook.com \
office365-mail-relay

docker logs -f mail-relay

