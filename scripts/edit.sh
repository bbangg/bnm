# Edit vhost file

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

if [ $# -lt 1 ]; then
    echo "${RED}ERROR:${RESET} invalid syntax."
    echo "${BLUE}SYNTAX:${RESET} ./nginx-manager.sh edit <domain>"
    exit 1
fi

DOMAIN="$2"
FILE_NAME="${DOMAIN}.conf"
FILE_PATH="data/nginx/conf.d/sites-available/${FILE_NAME}"

if [ ! -f "$FILE_PATH" ]; then
    echo "${RED}ERROR:${RESET} Host ${FILE_PATH} does not exist!"
    exit 1
fi

vi "$FILE_PATH"

echo "${GREEN}SUCCESS:${RESET} ${FILE_PATH} has been edited."