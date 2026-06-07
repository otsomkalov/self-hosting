setup_dir="$HOME/self-hosting/lan"

###
echo "Step 1. Disable sudo password prompt"

echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$USER

###
echo "Step 2. Update and upgrade the system"

sudo apt update && sudo apt upgrade -y

###
echo "Step 3. Remove snap"

sudo apt autoremove --purge snapd

###
echo "Step 4. Mount drive"

sudo mkdir /mnt
sudo mkdir /mnt/downloads
sudo lsblk

echo "Enter the device name of the drive you want to mount (e.g., /dev/sdb1):"
read drive
sudo mount -t ext4 $drive /mnt/downloads

echo "$drive /mnt/downloads ext4 defaults 0 0" | sudo tee -a /etc/fstab

###
echo "Step 4. Install Docker"

sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

###
echo "Step 5. Create Docker network"

docker network create general

###
echo "Step 6. Start ADO agent"

docker compose -f $setup_dir/ado-agent.compose.yml \
--env-file env.d/ado-agent.env \
up -d

###
echo "Step 7. Start Remove Sound TG Bot Dev"

docker compose -f $setup_dir/remove-sound-tg-bot-dev.compose.yml \
--env-file env.d/remove-sound-tg-bot-dev.env \
up -d

###
echo "Step 8. Start Webm to MP4 TG Bot Dev"

docker compose -f $setup_dir/webm-to-mp4-tg-bot-dev.compose.yml \
--env-file env.d/webm-to-mp4-tg-bot-dev.env \
up -d

###
echo "Step 9. Start MP4 to Webm TG Bot Dev"

docker compose -f $setup_dir/mp4-to-webm-tg-bot-dev.compose.yml \
--env-file env.d/mp4-to-webm-tg-bot-dev.env \
up -d

###
echo "Step 10. Start Remove Sound TG Bot"

docker compose -f $setup_dir/remove-sound-tg-bot.compose.yml \
--env-file env.d/remove-sound-tg-bot.env \
up -d

###
echo "Step 11. Start Webm to MP4 TG Bot"

docker compose -f $setup_dir/webm-to-mp4-tg-bot.compose.yml \
--env-file env.d/webm-to-mp4-tg-bot.env \
up -d

###
echo "Step 12. Start MP4 to Webm TG Bot"

docker compose -f $setup_dir/mp4-to-webm-tg-bot.compose.yml \
--env-file env.d/mp4-to-webm-tg-bot.env \
up -d

###
echo "Step 13. Start jackett"

docker compose -f $setup_dir/jackett.compose.yml \
--env-file env.d/jackett.env \
up -d

###
echo "Step 14. Start torrent"

docker compose -f $setup_dir/torrent.compose.yml \
--env-file env.d/torrent.env \
up -d

###
echo "Step 15. Start file browser"

docker compose -f $setup_dir/file-browser.compose.yml \
--env-file env.d/file-browser.env \
up -d

###
echo "Step 16. Setup Intel GPU drivers"

wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | sudo apt-key add -
sudo apt-add-repository 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main'
sudo apt update
sudo apt install -y intel-media-va-driver-non-free

echo "LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri" | sudo tee -a /etc/environment
echo "LIBVA_DRIVER_NAME=iHD" | sudo tee -a /etc/environment

###
echo "Step 17. Start jellyfin"

docker compose -f $setup_dir/jellyfin.compose.yml \
--env-file env.d/jellyfin.env \
up -d

sudo ufw allow 7359/udp

###
echo "Step 18. Start Home Assistant"

docker compose -f $setup_dir/home-assistant.compose.yml \
--env-file env.d/home-assistant.env \
up -d

###
echo "Step 19. Start Navidrome"

docker compose -f $setup_dir/navidrome.compose.yml \
--env-file env.d/navidrome.env \
up -d

docker compose -f $setup_dir/flac-splitter.compose.yml \
--env-file env.d/flac-splitter.env \
up -d

###
echo "Step 20. Start monitoring stack"

docker compose -f $setup_dir/monitoring.compose.yml \
--env-file env.d/monitoring.env \
up -d

###
echo "Step 21. Setup mkcert"

curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

###
echo "Step 22. Generate SSL certificates"

mkcert -install
mkcert *.server.local

###
echo "Step 23. Start Nginx"

docker compose -f $setup_dir/nginx.compose.yml \
--env-file env.d/nginx.env \
up -d

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp