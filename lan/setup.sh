setup_dir="$HOME/self-hosting/lan"

docker compose -f $setup_dir/nginx.yml \
-p nginx \
--env-file nginx.env \
up -d