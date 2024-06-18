#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

if ! [ -x "$(command -v docker)" ]; then
  echo -e "${RED}ERROR${RESET}: docker is not installed." >&2
  exit 1
fi

if [ $# -lt 1 ]; then
    echo -e "${BLUE}nginx-manager${RESET}: a simple, easy-to-use tool for managing nginx hosts.\n"

    scripts=$(find "$SCRIPT_DIR/scripts" -type f -name "*.sh")
    for script in $scripts; do
        description=$(head -1 $script)
        script_name=$(basename $script | sed 's/\.sh//g')
        echo -e "${YELLOW}$script_name${RESET}\t $description"
    done
    
    echo ""

    exit 1
fi

if ! find "$SCRIPT_DIR/scripts/$1.sh" &>/dev/null; then
    echo -e "${RED}ERROR${RESET}: Command '$1' not found!"
    echo "'./nginx-manager.sh' to see available commands."
    exit 1
fi

sh "$SCRIPT_DIR/scripts/$1.sh" "${@:1}"
