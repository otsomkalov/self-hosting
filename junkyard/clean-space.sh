docker compose -f $setup_dir/ado-agent.compose.yml --env-file ado-agent.env down -v
docker compose -f $setup_dir/ado-agent.compose.yml --env-file ado-agent.env up -d