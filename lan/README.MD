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