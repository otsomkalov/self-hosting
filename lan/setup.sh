setup_dir="$HOME/self-hosting/lan"

###
echo "Step 1. Mount drive"

sudo mkdir /mnt
sudo mkdir /mnt/data
sudo lsblk

echo "Enter the device name of the drive you want to mount (e.g., /dev/sdb1):"
read drive
sudo mount -t ext4 $drive /mnt/data

echo "$drive /mnt/data ext4 defaults 0 0" | sudo tee -a /etc/fstab

###
echo "Step 2. Start ADO agent"

docker compose -f $setup_dir/ado-agent.compose.yml \
--env-file env.d/ado-agent.env \
up -d

###
echo "Step 3. Start Remove Sound TG Bot Dev"

docker compose -f $setup_dir/remove-sound-tg-bot-dev.compose.yml \
--env-file env.d/remove-sound-tg-bot-dev.env \
up -d

###
echo "Step 4. Start Webm to MP4 TG Bot Dev"

docker compose -f $setup_dir/webm-to-mp4-tg-bot-dev.compose.yml \
--env-file env.d/webm-to-mp4-tg-bot-dev.env \
up -d

###
echo "Step 5. Start MP4 to Webm TG Bot Dev"

docker compose -f $setup_dir/mp4-to-webm-tg-bot-dev.compose.yml \
--env-file env.d/mp4-to-webm-tg-bot-dev.env \
up -d

###
echo "Step 6. Start Remove Sound TG Bot"

docker compose -f $setup_dir/remove-sound-tg-bot.compose.yml \
--env-file env.d/remove-sound-tg-bot.env \
up -d

###
echo "Step 7. Start Webm to MP4 TG Bot"

docker compose -f $setup_dir/webm-to-mp4-tg-bot.compose.yml \
--env-file env.d/webm-to-mp4-tg-bot.env \
up -d

###
echo "Step 8. Start MP4 to Webm TG Bot"

docker compose -f $setup_dir/mp4-to-webm-tg-bot.compose.yml \
--env-file env.d/mp4-to-webm-tg-bot.env \
up -d

###
echo "Step 9. Start file browser"

docker compose -f $setup_dir/file-browser.compose.yml \
--env-file env.d/file-browser.env \
up -d

###
echo "Step 10. Setup Intel GPU drivers"

wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | sudo apt-key add -
sudo apt-add-repository 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main'
sudo apt update
sudo apt install -y intel-media-va-driver-non-free

echo "LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri" | sudo tee -a /etc/environment
echo "LIBVA_DRIVER_NAME=iHD" | sudo tee -a /etc/environment

###
echo "Step 11. Start media stack"

docker compose -f $setup_dir/media.compose.yml \
--env-file env.d/media.env \
up -d

sudo ufw allow 7359/udp

###
echo "Step 12. Start Home Assistant"

docker compose -f $setup_dir/home-assistant.compose.yml \
--env-file env.d/home-assistant.env \
up -d

###
echo "Step 13. Start monitoring stack"

docker compose -f $setup_dir/monitoring.compose.yml \
--env-file env.d/monitoring.env \
up -d

###
echo "Step 14. Start Calibre Web"

docker compose -f $setup_dir/calibre.compose.yml \
--env-file env.d/calibre.env \
up -d

###
echo "Step 15. Setup mkcert"

curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

###
echo "Step 16. Generate SSL certificates"

mkcert -install
mkcert *.server.local

###
echo "Step 17. Start Nginx"

docker compose -f $setup_dir/nginx.compose.yml \
--env-file env.d/nginx.env \
up -d

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp