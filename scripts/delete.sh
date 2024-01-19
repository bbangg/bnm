# Delete the host

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

if [ $# -lt 2 ]; then
    echo "${RED}ERROR:${RESET} invalid syntax."
    echo "${BLUE}SYNTAX:${RESET} ./nginx-manager.sh delete <domain>"
    exit 1
fi

DOMAIN="$2"
FILE_NAME="${DOMAIN}.conf"

docker-compose exec nginx rm "/etc/nginx/conf.d/sites-enabled/${FILE_NAME}"
docker-compose exec nginx rm "/etc/nginx/conf.d/sites-available/${FILE_NAME}"
docker-compose exec nginx rm "/var/www/vhosts/${DOMAIN}"
docker-compose exec nginx rm "/var/log/nginx/${DOMAIN}"

echo "${GREEN}SUCCESS:${RESET} ${DOMAIN} has been deleted."