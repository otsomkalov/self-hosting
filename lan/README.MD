# LAN server

## Setup

1. Add `setup_dir="$HOME/self-hosting/lan"` to the `.bashrc`
2. Copy `.env` files to the `$HOME/env.d`
3. Run `setup.sh`

## Post-setup

### Grafana

1. Connect Prometheus using `http://prometheus:9090` URL
2. Add [Node exporter](https://grafana.com/grafana/dashboards/1860-node-exporter-full/) dashboard

### qBittorrent

[Setup](https://github.com/qbittorrent/search-plugins/wiki/How-to-configure-Jackett-plugin) torrent trackers indexers

### Home assistant

Add the next code to the `configuration.yaml`
```yaml
http:
  # For extra security set this to only accept connections on localhost if NGINX is on the same machine
  # Uncommenting this will mean that you can only reach Home Assistant using the proxy, not directly via IP from other clients.
  # server_host: 127.0.0.1
  use_x_forwarded_for: true
  # You must set the trusted proxy IP address so that Home Assistant will properly accept connections
  # Set this to your NGINX machine IP, or localhost if hosted on the same machine.
  trusted_proxies: <NGINX IP address here, or 127.0.0.1 if hosted on the same machine>
```

Install [HACS](https://hacs.xyz/docs/use/download/download/#to-download-hacs-container)
Install [EcoFlow Integration](https://github.com/tolwi/hassio-ecoflow-cloud)