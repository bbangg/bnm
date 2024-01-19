# Create a new host

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

if [ $# -lt 2 ]; then
    echo "${RED}ERROR:${RESET} invalid syntax."
    echo "${BLUE}SYNTAX:${RESET} ./nginx-manager.sh create <domain>"
    exit 1
fi

DOMAIN="$2"
FILE_NAME="${DOMAIN}.conf"
FILE_PATH="data/nginx/conf.d/sites-available/${FILE_NAME}"

# Check if file already exists
if [ -f "$FILE_PATH" ]; then
  echo "${RED}ERROR:${RESET} Host ${FILE_PATH} already exists!"
  exit 1
fi

ENABLED_PATH="data/nginx/conf.d/sites-enabled"
AVAILABLE_PATH="data/nginx/conf.d/sites-available"
LOGS_PATH="data/nginx/logs/${DOMAIN}"
DOMAIN_PATH="data/www/vhosts/${DOMAIN}"

if [ -d "$ENABLED_PATH" ]; then
    echo "${RED}ERROR:${RESET} ${ENABLED_PATH} already exists! Skipping.."
else
    echo "${YELLOW}INFO:${RESET} Creating ${ENABLED_PATH} for enabled hosts."
    mkdir -p "$ENABLED_PATH"
fi

if [ -d "$AVAILABLE_PATH" ]; then
    echo "${RED}ERROR:${RESET} ${AVAILABLE_PATH} already exists! Skipping.."
else
    echo "${YELLOW}INFO:${RESET} Creating ${AVAILABLE_PATH} for available hosts."
    mkdir -p "$AVAILABLE_PATH"
fi

if [ -d "$LOGS_PATH" ]; then
    echo "${RED}ERROR:${RESET} ${LOGS_PATH} already exists! Skipping.."
else
    echo "${YELLOW}INFO:${RESET} Creating ${LOGS_PATH} for logs."
    mkdir -p "$LOGS_PATH"
fi

if [ -d "$DOMAIN_PATH" ]; then
    echo "${RED}ERROR:${RESET} ${DOMAIN_PATH} already exists! Skipping.."
else
    echo "${YELLOW}INFO:${RESET} Creating ${DOMAIN_PATH} for serving files."
    mkdir -p "$DOMAIN_PATH"
fi

cat > "$DOMAIN_PATH/index.html" <<EOF
Hello World!
EOF

# Create file with template
cat > "$FILE_PATH" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    server_tokens off;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

# update
# server {
#    listen 443 ssl;
#    server_name www.${DOMAIN};
#    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
#    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
#    include /etc/letsencrypt/options-ssl-nginx.conf;
#    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
#    return 301 https://${DOMAIN}\$request_uri;
#}

server {
    listen 443 ssl;
    server_name ${DOMAIN};
    server_tokens off;

    error_log /var/log/nginx/${DOMAIN}/error.log notice;
    access_log /var/log/nginx/${DOMAIN}/access.log main;

    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass  http://${DOMAIN};
        proxy_set_header    Host                \$http_host;
        proxy_set_header    X-Real-IP           \$remote_addr;
        proxy_set_header    X-Forwarded-For     \$proxy_add_x_forwarded_for;
    }
    # update
    # root /var/www/vhosts/${DOMAIN};
    # index index.html index.php;
}
EOF

echo "${GREEN}SUCCESS:${RESET} Host ${FILE_PATH} created."
