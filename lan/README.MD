# LAN server

The order of setup is:
1. [Portainer][1]
2. [qBittorrent][2] + [Jellyfin][3] + [Plex][4]
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
[2]: https://github.com/linuxserver/docker-qbittorrent#docker-compose-recommended-click-here-for-more-info
[3]: https://jellyfin.org/docs/general/installation/container/#using-docker-compose
[4]: https://github.com/linuxserver/docker-plex#docker-compose-recommended-click-here-for-more-info
[5]: https://hub.docker.com/_/nginx/