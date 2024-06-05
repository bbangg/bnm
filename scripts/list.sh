# List enabled vhosts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

if [ $# -lt 1 ]; then
    echo "${RED}ERROR:${RESET} invalid syntax."
    echo "${BLUE}SYNTAX:${RESET} ./nginx-manager.sh list \"enabled|available\""
    exit 1
fi

TYPE="$2"

if [ "$TYPE" != "enabled" ] && [ "$TYPE" != "available" ]; then
    echo "${RED}ERROR:${RESET} invalid type."
    echo "${BLUE}TYPE:${RESET} enabled|available"
    exit 1
fi

if [ "$TYPE" = "enabled" ]; then
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
    exit 0
fi

if [ "$TYPE" = "available" ]; then
    AVAILABLE_PATH="data/nginx/conf.d/sites-available"
    if [ -d "$AVAILABLE_PATH" ]; then
        echo "${YELLOW}INFO:${RESET} Listing available vhosts.."
        files=$(ls -1 "$AVAILABLE_PATH" | sed 's/\.conf$//')
        for file in $files; do
            echo "$file"
        done
    else
        echo "${RED}ERROR:${RESET} ${AVAILABLE_PATH} does not exist!"
    fi
    exit 0
fi