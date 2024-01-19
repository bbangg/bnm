# Reload nginx

YELLOW='\033[0;33m'
RESET='\033[0m'

echo "${YELLOW}INFO:${RESET} Reloading nginx.."

docker-compose exec nginx nginx -s reload