# List enabled vhosts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

ENABLED_PATH="data/nginx/conf.d/sites-enabled"

if [ -d "$ENABLED_PATH" ]; then
    echo "${YELLOW}INFO:${RESET} Listing enabled vhosts.."
    files=$(ls -1 "$ENABLED_PATH" | sed 's/\.conf$//')
    for file in $files; do
        echo "$file"
    done
else
    echo "${RED}ERROR:${RESET} ${ENABLED_PATH} does not exist!"
fi