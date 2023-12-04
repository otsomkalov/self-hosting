# Cloud server 

The order of setup is:
1. [Portainer][1]
2. [Wireguard][2] + [AdGuard Home][3] + [TG BOT API][4]
3. [NGINX][5]

# Portainer

Used to manage stacks & containers.

# DNS

DNS filtering implemented using AdGuard Home

## SSL

You'll need valid SLL cert to secure your connection to the site and enable DoT and DoH

1. Get wildcard cert for domain:
    1. Configure DNS redirect using domain provider
    2. `certbot certonly --manual --preferred-challenges=dns --email <email> --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.<domain>`

[1]: https://github.com/portainer/portainer
[2]: https://github.com/wg-easy/wg-easy#2-run-wireguard-easy
[3]: https://github.com/AdguardTeam/AdGuardHome/wiki/Docker#create-and-run-the-container
[4]: https://github.com/aiogram/telegram-bot-api#usage-via-docker-stack-deploy-or-docker-compose
[5]: https://hub.docker.com/_/nginx/