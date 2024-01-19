# Enable the host

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RESET='\033[0m'

if [ $# -lt 2 ]; then
    echo "${RED}ERROR:${RESET} invalid syntax."
    echo "${BLUE}SYNTAX:${RESET} ./nginx-manager.sh enable <domain>"
    exit 1
fi

DOMAIN="$2"
FILE_NAME="${DOMAIN}.conf"
FILE_PATH="data/nginx/conf.d/sites-available/${FILE_NAME}"
LOGS_PATH="data/nginx/logs/${DOMAIN}"

docker-compose exec nginx ln -s "/etc/nginx/conf.d/sites-available/${FILE_NAME}" "/etc/nginx/conf.d/sites-enabled/${FILE_NAME}"

if ! [ -d "$LOGS_PATH" ]; then
    echo "${YELLOW}INFO:${RESET} Creating ${LOGS_PATH} for logs."
    mkdir -p "$LOGS_PATH"
fi

echo "${GREEN}SUCCESS:${RESET} ${DOMAIN} has been enabled."