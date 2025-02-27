# Cloud server

# Basic setup

1. Create user
```bash
sudo adduser <user>
usermod -aG sudo <user>
```
2. Disable root password login in /etc/ssh/sshd_config
```
PermitRootLogin prohibit-password
```
3. Install Docker and configure
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

## SSH

### Client

**Windows**

1. Generate SSH key:
    ```bash
    ssh-keygen -t rsa -b 4096
    ```

    By default, keys will be put into the USERPROFILE directory.

2. Put SSH key to server:
    ```bash
    cat ~/.ssh/id_rsa.pub | ssh user@address "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    ```

3. Enable `ssh-agent` service
    ```
    Get-Service -Name ssh-agent | Set-Service -StartupType Automatic
    ```

4. Add key to ssh-agent
    ```
    ssh-add ~\.ssh\id_rsa
    ```

### Server

In `/etc/ssh/sshd_config` set:

```
PasswordAuthentication no
ChallengeResponseAuthentication no
```

# Services

The order of setup is:

1. [Portainer][1]
2. [Wireguard][2] + [AdGuard Home][3] + [TG BOT API][4]
3. [NGINX][5]

## Portainer

Used to manage stacks & containers.

Create it providing `-p` flag with `general` value

## DNS

DNS filtering implemented using AdGuard Home

### SSL

You'll need valid SLL cert to secure your connection to the site and enable DoT and DoH

1. Get wildcard cert for domain:
   1. Configure DNS redirect using domain provider
   2. `sudo snap install --classic certbot`
   3. `certbot certonly --manual --preferred-challenges=dns --email <email> --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.<domain>`

[1]: https://github.com/portainer/portainer
[2]: https://github.com/wg-easy/wg-easy#2-run-wireguard-easy
[3]: https://github.com/AdguardTeam/AdGuardHome/wiki/Docker#create-and-run-the-container
[4]: https://github.com/aiogram/telegram-bot-api#usage-via-docker-stack-deploy-or-docker-compose
[5]: https://hub.docker.com/_/nginx/