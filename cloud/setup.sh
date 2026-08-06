###
echo "Step 1. Start AdGuard Home"

docker compose -f $setup_dir/dns.compose.yml \
--env-file env.d/dns.env \
up -d

###
echo "Step 2. Start Mongo"

docker compose -f $setup_dir/mongo.compose.yml \
--env-file env.d/mongo.env \
up -d

###
echo "Step 3. Start PostgreSQL"

docker compose -f $setup_dir/pg.compose.yml \
--env-file env.d/pg.env \
up -d

###
echo "Step 4. Start Redis"

docker compose -f $setup_dir/redis.compose.yml \
--env-file env.d/redis.env \
up -d

###
echo "Step 5. Start Keycloak"

docker compose -f $setup_dir/keycloak.compose.yml \
--env-file env.d/keycloak.env \
up -d

###
echo "Step 6. Start Telegram Bot API"

docker compose -f $setup_dir/tg-bot-api.compose.yml \
--env-file env.d/tg-bot-api.env \
up -d

###
echo "Step 7. Start WireGuard VPN"

docker compose -f $setup_dir/vpn.compose.yml \
--env-file env.d/vpn.env \
up -d

###
echo "Step 8. Start Nginx"

docker compose -f $setup_dir/nginx.compose.yml \
--env-file env.d/nginx.env \
up -d