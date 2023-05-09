#!/bin/bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

if [ $# -lt 1 ]; then
    echo "Error: no command name provided!"
    exit 1
fi

if [ "$1" == "create" ]; then

if [ $# -lt 2 ]; then
    echo "Error: invalid syntax."
    echo "Syntax:  ./bws.sh create <domain>"
    echo "Example: ./bws.sh create example.org"
    exit 1
fi

DOMAIN="$2"
FILE_NAME="${DOMAIN}.conf"
FILE_PATH="data/nginx/conf.d/sites-available/${FILE_NAME}"
DOMAIN_PATH="data/www/${DOMAIN}"

# Check if file already exists
if [ -f "$FILE_PATH" ]; then
  echo "Error: Host ${FILE_PATH} already exists!"
  exit 1
fi

ENABLED_PATH="data/nginx/conf.d/sites-enabled"
AVAILABLE_PATH="data/nginx/conf.d/sites-available"

if [ -d "$ENABLED_PATH" ]; then
    echo "Error: ${ENABLED_PATH} already exists! Skipping.."
else
    echo "Info: Creating ${ENABLED_PATH} for enabled hosts."
    mkdir -p "$ENABLED_PATH"
fi

if [ -d "$AVAILABLE_PATH" ]; then
    echo "Error: ${AVAILABLE_PATH} already exists! Skipping.."
else
    echo "Info: Creating ${AVAILABLE_PATH} for available hosts."
    mkdir -p "$AVAILABLE_PATH"
fi

if [ -d "$DOMAIN_PATH" ]; then
    echo "Error: ${DOMAIN_PATH} already exists! Skipping.."
else
    echo "Info: Creating ${DOMAIN_PATH} for serving files."
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

server {
    listen 443 ssl;
    server_name www.${DOMAIN};
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    return 301 https://${DOMAIN}\$request_uri;
}

server {
    listen 443 ssl;
    server_name ${DOMAIN};
    server_tokens off;

    error_log /var/log/nginx/${DOMAIN}/error.log notice;
    access_log /var/log/nginx/${DOMAIN}/access.log grafana_logs;

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

    root /var/www/${DOMAIN}
    index index.html index.php
}
EOF

echo "### Host ${FILE_PATH} created."
echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload

elif [ "$1" == "enable" ]; then

if [ $# -lt 2 ]; then
    echo "Error: invalid syntax."
    echo "Syntax:  ./bws.sh enable <domain>"
    echo "Example: ./bws.sh enable example.org"
    exit 1
fi

DOMAIN="$2"
FILE_NAME="${DOMAIN}.conf"
FILE_PATH="data/nginx/conf.d/sites-available/${FILE_NAME}"

docker-compose exec nginx ln -s "/etc/nginx/conf.d/sites-available/${FILE_NAME}" "/etc/nginx/conf.d/sites-enabled/${FILE_NAME}"
echo "### ${DOMAIN} has been enabled."

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload

elif [ "$1" == "disable" ]; then

if [ $# -lt 2 ]; then
    echo "Error: invalid syntax."
    echo "Syntax:  ./bws.sh disable <domain>"
    echo "Example: ./bws.sh disable example.org"
    exit 1
fi

DOMAIN="$2"
FILE_NAME="${DOMAIN}.conf"

docker-compose exec nginx rm "/etc/nginx/conf.d/sites-enabled/${FILE_NAME}"
echo "### ${DOMAIN} has been disabled."

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload

elif [ "$1" == "ssl" ]; then

if [ $# -lt 3 ]; then
    echo "Error: invalid syntax."
    echo "Syntax:  ./bws.sh ssl <mail> <staging> <domains>"
    echo "Example: ./bws.sh ssl example@mail.com 0 example.org www.example.org"
    exit 1
fi

domains="${@:3}"
rsa_key_size=4096
data_path="./data/certbot"
email="$2"
staging="$3" # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi


if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo


echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo


echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload

elif [ "$1" == "purge" ]; then

read -p "### Continue and delete existing files? (y/N) " decision
if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
  exit
fi

rm "data/www" -rf
rm "data/certbot" -rf
rm "data/nginx/conf.d/sites-available" -rf
rm "data/nginx/conf.d/sites-enabled" -rf
rm "data/nginx/logs/*" -rf

else
    # If the first argument is not recognized, print an error message
    echo "Error: unrecognized command '$1'"
    exit 1
fi